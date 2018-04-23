Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0476B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 18:41:11 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id o66-v6so9827941iof.17
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 15:41:11 -0700 (PDT)
Received: from resqmta-po-01v.sys.comcast.net (resqmta-po-01v.sys.comcast.net. [2001:558:fe16:19:96:114:154:160])
        by mx.google.com with ESMTPS id t70-v6si7629292itf.56.2018.04.23.15.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 15:41:09 -0700 (PDT)
Date: Mon, 23 Apr 2018 17:41:06 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] SLUB: Do not fallback to mininum order if __GFP_NORETRY
 is set
In-Reply-To: <26580de4-70b5-90f7-b3b9-22f57ba38843@suse.cz>
Message-ID: <alpine.DEB.2.20.1804231738020.3811@nuc-kabylake>
References: <alpine.DEB.2.20.1804180944180.1062@nuc-kabylake> <20180419110051.GB16083@dhcp22.suse.cz> <alpine.DEB.2.20.1804200952230.18006@nuc-kabylake> <26580de4-70b5-90f7-b3b9-22f57ba38843@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Mikulas Patocka <mpatocka@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Sat, 21 Apr 2018, Vlastimil Babka wrote:

> > The problem is that SLUB does not honor GFP_NORETRY. The semantics of
> > GFP_NORETRY are not followed.
>
> The caller might want SLUB to try hard to get that high-order page that
> will minimize memory waste (e.g. 2MB page for 3 640k objects), and
> __GFP_NORETRY will kill the effort on allocating that high-order page.

Well yes since *_NORETRY says that fallbacks are acceptable.

> Thus, using __GPF_NORETRY for "please give me a space-optimized object,
> or nothing (because I have a fallback that's better than wasting memory,
> e.g. by using 1MB page for 640kb object)" is not ideal.
>
> Maybe __GFP_RETRY_MAYFAIL is a better fit? Or perhaps indicate this
> situation to SLUB with e.g. __GFP_COMP, although that's rather ugly?

Yuck. None of that sounds like an intuitive approach.
