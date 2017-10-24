Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 20BF06B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 04:33:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 11so8376956wrb.10
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 01:33:21 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id 128si678730wmr.119.2017.10.24.01.33.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 01:33:19 -0700 (PDT)
Subject: Re: PROBLEM: Remapping hugepages mappings causes kernel to return
 EINVAL
References: <20171023114210.j7ip75ewoy2tiqs4@dhcp22.suse.cz>
 <e2cc07b7-3c5e-a166-0bb2-eff92fc70cd1@gmx.de>
 <20171023124122.tjmrbcwo2btzk3li@dhcp22.suse.cz>
 <b6cbb960-d0f1-0630-a2a1-e00bab4af0a1@gmx.de>
 <20171023161316.ajrxgd2jzo3u52eu@dhcp22.suse.cz>
 <93ffc1c8-3401-2bea-732a-17d373d2f24c@gmx.de>
 <20171023165717.qx5qluryshz62zv5@dhcp22.suse.cz>
 <b138bcf8-0a66-a988-4040-520d767da266@gmx.de>
 <20171023180232.luayzqacnkepnm57@dhcp22.suse.cz>
 <0c934e18-5436-792f-2b2c-ebca3ae2d786@gmx.de>
 <20171024081232.6to62flr7h3qgxvv@dhcp22.suse.cz>
From: "C.Wehrmeyer" <c.wehrmeyer@gmx.de>
Message-ID: <e1e39e93-5746-6a69-355f-228f00a05213@gmx.de>
Date: Tue, 24 Oct 2017 10:32:59 +0200
MIME-Version: 1.0
In-Reply-To: <20171024081232.6to62flr7h3qgxvv@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>

On 2017-10-24 10:12, Michal Hocko wrote:
> On Tue 24-10-17 09:41:46, C.Wehrmeyer wrote:
> [...]
>> 1. Provide mmap with some sort of flag (which would be redundant IMHO) in
>> order to churn out properly aligned pages (not transparent, but the current
>> MAP_HUGETLB flag isn't either).
> 
> You can easily implement such a thing in userspace. In fact glibc has
> already done that for you.

That's not the point. The point is that it's not *transparent*. Let me 
paraphrase your statements:

"Yes, you can have hugepages by just allocating things normally. THPs 
will then be used - maybe. Even though you might know best how much 
memory you actually require it requires you to fiddle with the mappings 
in order to get complete hugepages coverage, because mmap does not 
provide a mechanism for that. Or you can just live with your mappings 
only being half-hugepaged. How is that not transparent?"

Unfortunately the ratio (512) is big enough that I'm not completely OK 
with that. And in the distant future, when we all use 1-GiB pages, that 
ratio becomes even bigger.

> [...]
> I think there is still some confusion here. Kernel will try to fault in
> THP pages on properly aligned addresses. So if you create a larger
> mapping than the THP size then you will get a THP (assuming the memory
> is not fragmented). It is just the unaligned addresses will get regular
> pages.

OK, I wasn't sure about that one as well - which is why I didn't dare to 
lay hands on the kernel. It DOES support variable-sized-pages. That does 
not change the fact, however, that when THPs are enabled mmap should 
give userspace properly aligned pages exactly to avoid those smaller pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
