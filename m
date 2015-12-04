Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5886B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 08:35:49 -0500 (EST)
Received: by pfbg73 with SMTP id g73so27131319pfb.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 05:35:49 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id t6si19491311pfa.123.2015.12.04.05.35.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 05:35:48 -0800 (PST)
Received: by pacej9 with SMTP id ej9so87360148pac.2
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 05:35:48 -0800 (PST)
Date: Fri, 4 Dec 2015 22:35:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151204133537.GA11951@blaptop>
References: <20151203085451.GC9264@dhcp22.suse.cz>
 <20151203125950.GA1428@bbox>
 <20151203133719.GF9264@dhcp22.suse.cz>
 <20151203134326.GG9264@dhcp22.suse.cz>
 <20151203145850.GH9264@dhcp22.suse.cz>
 <20151203154729.GI9264@dhcp22.suse.cz>
 <20151204053515.GA5174@blaptop>
 <20151204085226.GB10021@dhcp22.suse.cz>
 <20151204091634.GB5174@blaptop>
 <20151204095815.GC10021@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151204095815.GC10021@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 04, 2015 at 10:58:15AM +0100, Michal Hocko wrote:
> On Fri 04-12-15 18:16:34, Minchan Kim wrote:
> > On Fri, Dec 04, 2015 at 09:52:27AM +0100, Michal Hocko wrote:
> > > On Fri 04-12-15 14:35:15, Minchan Kim wrote:
> > > > On Thu, Dec 03, 2015 at 04:47:29PM +0100, Michal Hocko wrote:
> > > > > On Thu 03-12-15 15:58:50, Michal Hocko wrote:
> > > > > [....]
> > > > > > Warning, this looks ugly as hell.
> > > > > 
> > > > > I was thinking about it some more and it seems that we should rather not
> > > > > bother with partial thp at all and keep it in the original memcg
> > > > > instead. It is way much less code and I do not think this will be too
> > > > > disruptive. Somebody should be holding the thp head, right?
> > > > > 
> > > > > Minchan, does this fix the issue you are seeing.
> > > > 
> > > > This patch solves the issue but not sure it's right approach.
> > > > I think it could make regression that in old, we could charge
> > > > a THP page but we can't now.
> > > 
> > > The page would still get charged when allocated. It just wouldn't get
> > > moved when mapped only partially. IIUC there will be still somebody
> > > mapping the THP head via pmd, right? That process will move the page to
> > 
> > If I read code correctly, No. The split_huge_pmd splits just pmd,
> > not page itself. IOW, it could be possible !pmd_trans_huge(pmd) &&
> > PageTransHuge although there is only process owns the page.
> 
> I am not sure I follow you. I thought there would still be other pmd
> which will hold the THP. Why should we keep the page as huge when all
> processes which map it have already split it up?

I didn't follow Kirill's work but just read part of code to implement
MADV_FREE so I just guess.
(high-order-alloc-and-compaction/split/collapse) are costly operations
so new work tried to avoid split page as far as possible.
For example, if it works with splitting pmd, not THP page,
it doesn't split the THP page where in mprotect path.
Even, it could do delay split-page via deferred _split_huge_page
even if THP page is freed.

> 
> On the other hand it is true that the last process which maps the whole
> thp might have exited and leave others to map it partially.
>  
> > > the new memcg when moved. Or is it possible that we will end up only
> > > with pte mapped THP from all processes? Kirill?
> > 
> > I'm not Kirill but I think it's possible.
> > If so, a thing we can use is page_mapcount(page) == 1. With that,
> > it could gaurantee only a process owns the page so charge 512 instead of 1?
> 
> Alright the exclusive holder should indeed move it. I will think how to
> simplify the previous patch (has it helped in your testing btw.?).

At least, your patch doesn't make the WARNING but I didn't check
the accouting was right.

Thanks.

> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
