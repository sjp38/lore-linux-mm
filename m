Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 748DF6B0062
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 04:35:42 -0400 (EDT)
Message-ID: <5081122D.1030906@cn.fujitsu.com>
Date: Fri, 19 Oct 2012 16:41:17 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 8/9] memory-hotplug: fix NR_FREE_PAGES mismatch
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com> <1350629202-9664-9-git-send-email-wency@cn.fujitsu.com> <CAHGf_=ohk--=AKesgm+3U2qsSvjaVFBXn9c1KDru40GEpbM7gA@mail.gmail.com>
In-Reply-To: <CAHGf_=ohk--=AKesgm+3U2qsSvjaVFBXn9c1KDru40GEpbM7gA@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, Christoph Lameter <cl@linux.com>

At 10/19/2012 03:41 PM, KOSAKI Motohiro Wrote:
> On Fri, Oct 19, 2012 at 2:46 AM,  <wency@cn.fujitsu.com> wrote:
>> From: Wen Congyang <wency@cn.fujitsu.com>
>>
>> NR_FREE_PAGES will be wrong after offlining pages. We add/dec NR_FREE_PAGES
>> like this now:
>> 1. mova all pages in buddy system to MIGRATE_ISOLATE, and dec NR_FREE_PAGES
> 
> move?

Yes.
__offline_pages()
    start_isolate_page_range()
        set_migratetype_isolate()
            move_freepages_block()  // move all pages in buddy system to MIGRATE_ISOLATE
            __mod_zone_freepage_state() // dec NR_FREE_PAGES

> 
>> 2. don't add NR_FREE_PAGES when it is freed and the migratetype is MIGRATE_ISOLATE
>> 3. dec NR_FREE_PAGES when offlining isolated pages.
>> 4. add NR_FREE_PAGES when undoing isolate pages.
>>
>> When we come to step 3, all pages are in MIGRATE_ISOLATE list, and NR_FREE_PAGES
>> are right. When we come to step4, all pages are not in buddy system, so we don't
>> change NR_FREE_PAGES in this step, but we change NR_FREE_PAGES in step3. So
>> NR_FREE_PAGES is wrong after offlining pages. So there is no need to change
>> NR_FREE_PAGES in step3.
> 
> Sorry, I don't understand this two paragraph. Can  you please elaborate more?

OK.

If we don't online/offline memory, we add NR_FREE_PAGES when we free a page,
and dec it when allocate a page. If we put the page into pcp, we don't add
NR_FREE_PAGES. We will add it when the page is moved to buddy system from pcp.

When we offline a memory section, we should dec NR_FREE_PAGES(we will add it
when onlining memory section). The pages may be freed or inuse:
1. If the page is freed, and in buddy system. We move it to MIGRATE_ISOLATE,
   and dec NR_FREE_PAGES
2. If the page is inuse, we will migrate them to other memory section and free
   them. We don't dec NR_FREE_PAGES when it is freed because we have decreased
   it when it is allocated. We just put them in MIGRATE_ISOLATE.
3. If the page is in pcp, we call drain_all_pages() to put them to MIGRATE_ISOLATE.
   We have decreased NR_FREE_PAGES when we allocate a page and put it in pcp.
   So we just put them in MIGRATE_ISOLATE.

Step1 deals with case1, and step2 deals with case2,3

So NR_FREE_PAGES is right after all pages are put into MIGRATE_ISOLATE list.
Now offline_isolated_pages() will be called after all pages are put in
MIGRATE_ISOLATE list. So we should not change NR_FREE_PAGES now, but
we dec NR_FREE_PAGES in offline_isolated_pages().

> 
> and one more trivial question: why do we need to call
> undo_isolate_page_range() from
> __offline_pages()?

We need to restore the page's migrate type to MIGRATE_MOVABLE.

> 
> 
>>
>> This patch also fixs a problem in step2: if the migratetype is MIGRATE_ISOLATE,
>> we should not add NR_FRR_PAGES when we remove pages from pcppages.
> 
> Why drain_all_pages doesn't work?
> 

drain_all_pages() deals with case3, and it should not touch NR_FREE_PAGES if it
put a page to MIGRATE_ISOLATE list. But we touch NR_FREE_PAGES without checking
where the page is put.

Thanks
Wen Congyang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
