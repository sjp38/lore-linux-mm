Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 27FAA6B0073
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 13:40:35 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id y19so15281931wgg.2
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 10:40:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id li1si5743070wjc.90.2015.02.06.10.40.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Feb 2015 10:40:33 -0800 (PST)
Message-ID: <54D50A87.8000902@redhat.com>
Date: Fri, 06 Feb 2015 13:40:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
References: <20141130235652.GA10333@bbox> <20141202100125.GD27014@dhcp22.suse.cz> <20141203000026.GA30217@bbox> <20141203101329.GB23236@dhcp22.suse.cz> <20141205070816.GB3358@bbox> <20141205083249.GA2321@dhcp22.suse.cz> <54D0F9BC.4060306@gmail.com> <20150203234722.GB3583@blaptop> <20150206003311.GA2347@kernel.org> <20150206125825.GA4498@dhcp22.suse.cz> <20150206183242.GB2290@kernel.org>
In-Reply-To: <20150206183242.GB2290@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/06/2015 01:32 PM, Shaohua Li wrote:
> On Fri, Feb 06, 2015 at 01:58:25PM +0100, Michal Hocko wrote:
>> On Thu 05-02-15 16:33:11, Shaohua Li wrote: [...]
>>> Did you think about move the MADV_FREE pages to the head of
>>> inactive LRU, so they can be reclaimed easily?
>> 
>> Yes this makes sense for pages living on the active LRU list. I
>> would preserve LRU ordering on the inactive list because there is
>> no good reason to make the operation more costly for inactive
>> pages. On the other hand having tons of to-be-freed pages on the
>> active list clearly sucks. Care to send a patch?
> 
> Considering anon pages are in active LRU first, it's likely
> MADV_FREE pages are in active list. I'm curious why preserves the
> order of inactive list.

Only before the first time MADV_FREE is called on those pages.

If a program repeatedly allocates and frees the same memory
region, not moving the MADV_FREE pages around in the LRU
several times can save some overhead.

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU1QqHAAoJEM553pKExN6DTXoH/3bS+VhdIm1EpOc8OOFtBHvd
T63DHObtOY1FOog48CtgvUCfo7Q+g1aG/9hz7lJNP1G26B3+LNszM9OtE/9QrYUH
uzmuWvFL7l0W0qen/WsyO0RcyqN+0mEXvNVqynTmJJu8qAG0p5WsjA6L5Penzj//
tnBmn5xb1h3COjDZkHsxBfkpfCpNq5dm88K6B3nApHz4QhfcviKefczsrWdZ/bBc
2uMnlIebKY1Oq9MDHsg8p/b3lIHzwAf0xGSvGLN0YfzDPzlqBMbxSbVubYEA9EaU
OiS1XqRp8okeGgrxsRAb/F8wPgClpce+h0E5xpyUuew2rlD1OmciX6iIDcE5Zrk=
=KUng
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
