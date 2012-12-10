Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id A69776B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 07:47:50 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so2079341pad.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 04:47:49 -0800 (PST)
Message-ID: <1355143664.1821.8.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH V2] MCE: fix an error of mce_bad_pages statistics
From: Simon Jeons <simon.jeons@gmail.com>
Date: Mon, 10 Dec 2012 06:47:44 -0600
In-Reply-To: <50C5D844.8050707@huawei.com>
References: <50C1AD6D.7010709@huawei.com>
	   <20121207141102.4fda582d.akpm@linux-foundation.org>
	   <20121210083342.GA31670@hacker.(null)> <50C5A62A.6030401@huawei.com>
	  <1355136423.1700.2.camel@kernel.cn.ibm.com> <50C5C4A2.2070002@huawei.com>
	 <1355140561.1821.5.camel@kernel.cn.ibm.com> <50C5D844.8050707@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Vyacheslav.Dubeyko@huawei.com, Borislav Petkov <bp@alien8.de>, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wency@cn.fujitsu.com

Cc other guys.

On Mon, 2012-12-10 at 20:40 +0800, Xishi Qiu wrote:
> On 2012/12/10 19:56, Simon Jeons wrote:
> 
> > On Mon, 2012-12-10 at 19:16 +0800, Xishi Qiu wrote:
> >> On 2012/12/10 18:47, Simon Jeons wrote:
> >>
> >>> On Mon, 2012-12-10 at 17:06 +0800, Xishi Qiu wrote:
> >>>> On 2012/12/10 16:33, Wanpeng Li wrote:
> >>>>
> >>>>> On Fri, Dec 07, 2012 at 02:11:02PM -0800, Andrew Morton wrote:
> >>>>>> On Fri, 7 Dec 2012 16:48:45 +0800
> >>>>>> Xishi Qiu <qiuxishi@huawei.com> wrote:
> >>>>>>
> >>>>>>> On x86 platform, if we use "/sys/devices/system/memory/soft_offline_page" to offline a
> >>>>>>> free page twice, the value of mce_bad_pages will be added twice. So this is an error,
> >>>>>>> since the page was already marked HWPoison, we should skip the page and don't add the
> >>>>>>> value of mce_bad_pages.
> >>>>>>>
> >>>>>>> $ cat /proc/meminfo | grep HardwareCorrupted
> >>>>>>>
> >>>>>>> soft_offline_page()
> >>>>>>> 	get_any_page()
> >>>>>>> 		atomic_long_add(1, &mce_bad_pages)
> >>>>>>>
> >>>>>>> ...
> >>>>>>>
> >>>>>>> --- a/mm/memory-failure.c
> >>>>>>> +++ b/mm/memory-failure.c
> >>>>>>> @@ -1582,8 +1582,11 @@ int soft_offline_page(struct page *page, int flags)
> >>>>>>>  		return ret;
> >>>>>>>
> >>>>>>>  done:
> >>>>>>> -	atomic_long_add(1, &mce_bad_pages);
> >>>>>>> -	SetPageHWPoison(page);
> >>>>>>>  	/* keep elevated page count for bad page */
> >>>>>>> +	if (!PageHWPoison(page)) {
> >>>>>>> +		atomic_long_add(1, &mce_bad_pages);
> >>>>>>> +		SetPageHWPoison(page);
> >>>>>>> +	}
> >>>>>>> +
> >>>>>>>  	return ret;
> >>>>>>>  }
> >>>>>>
> >>>>>> A few things:
> >>>>>>
> >>>>>> - soft_offline_page() already checks for this case:
> >>>>>>
> >>>>>> 	if (PageHWPoison(page)) {
> >>>>>> 		unlock_page(page);
> >>>>>> 		put_page(page);
> >>>>>> 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
> >>>>>> 		return -EBUSY;
> >>>>>> 	}
> >>>>>>
> >>>>>>  so why didn't this check work for you?
> >>>>>>
> >>>>>>  Presumably because one of the earlier "goto done" branches was
> >>>>>>  taken.  Which one, any why?
> >>>>>>
> >>>>>>  This function is an utter mess.  It contains six return points
> >>>>>>  randomly intermingled with three "goto done" return points.
> >>>>>>
> >>>>>>  This mess is probably the cause of the bug you have observed.  Can
> >>>>>>  we please fix it up somehow?  It *seems* that the design (lol) of
> >>>>>>  this function is "for errors, return immediately.  For success, goto
> >>>>>>  done".  In which case "done" should have been called "success".  But
> >>>>>>  if you just look at the function you'll see that this approach didn't
> >>>>>>  work.  I suggest it be converted to have two return points - one for
> >>>>>>  the success path, one for the failure path.  Or something.
> >>>>>>
> >>>>>> - soft_offline_huge_page() is a miniature copy of soft_offline_page()
> >>>>>>  and might suffer the same bug.
> >>>>>>
> >>>>>> - A cleaner, shorter and possibly faster implementation is
> >>>>>>
> >>>>>> 	if (!TestSetPageHWPoison(page))
> >>>>>> 		atomic_long_add(1, &mce_bad_pages);
> >>>>>>
> >>>>>
> >>>>> Hi Andrew,
> >>>>>
> >>>>> Since hwpoison bit for free buddy page has already be set in get_any_page, 
> >>>>> !TestSetPageHWPoison(page) will not increase mce_bad_pages count even for 
> >>>>> the first time.
> >>>>>
> >>>>> Regards,
> >>>>> Wanpeng Li
> >>>>>
> >>>>
> >>>> The poisoned page is isolated in bad_page(), I wonder whether it could be isolated
> >>>> immediately in soft_offline_page() and memory_failure()?
> >>>>
> >>>> buffered_rmqueue()
> >>>> 	prep_new_page()
> >>>> 		check_new_page()
> >>>> 			bad_page()
> >>>
> >>> Do you mean else if(is_free_buddy_page(p)) branch is redundancy?
> >>>
> >>
> >> Hi Simon,
> >>
> >> get_any_page() -> "else if(is_free_buddy_page(p))" branch is *not* redundancy.
> >>
> >> It is another topic, I mean since the page is poisoned, so why not isolate it
> > 
> > What topic? I still can't figure out when this branch can be executed
> > since hwpoison inject path can't poison free buddy pages. 
> > 
> 
> Hi Simon,
> 
> If we use "/sys/devices/system/memory/soft_offline_page" to offline a
> free page, the value of mce_bad_pages will be added. Then the page is marked
> HWPoison, but it is still managed by page buddy alocator.
> 
> So if we offline it again, the value of mce_bad_pages will be added again.
> Assume the page is not allocated during this short time.
> 
> soft_offline_page()
> 	get_any_page()
> 		"else if (is_free_buddy_page(p))" branch return 0
> 			"goto done";
> 				"atomic_long_add(1, &mce_bad_pages);"
> 
> I think it would be better to move "if(PageHWPoison(page))" at the beginning of
> soft_offline_page(). However I don't know what do these words mean,
> "Synchronized using the page lock with memory_failure()"
> 
> >> from page buddy alocator in soft_offline_page() rather than in check_new_page().
> >>
> >> I find soft_offline_page() only migrate the page and mark HWPoison, the poisoned
> >> page is still managed by page buddy alocator.
> >>
> >>>>
> >>>> Thanks
> >>>> Xishi Qiu
> >>>>
> >>>>>> - We have atomic_long_inc().  Use it?
> >>>>>>
> >>>>>> - Why do we have a variable called "mce_bad_pages"?  MCE is an x86
> >>>>>>  concept, and this code is in mm/.  Lights are flashing, bells are
> >>>>>>  ringing and a loudspeaker is blaring "layering violation" at us!
> >>>>>>
> >>
> >>
> > 
> > 
> > 
> > .
> > 
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
