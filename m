Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 5921F6B0138
	for <linux-mm@kvack.org>; Sat, 18 Feb 2012 01:35:42 -0500 (EST)
Received: by bkty12 with SMTP id y12so4676564bkt.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 22:35:40 -0800 (PST)
Message-ID: <4F3F46B7.40100@openvz.org>
Date: Sat, 18 Feb 2012 10:35:35 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 00/15] mm: memory book keeping and lru_lock splitting
References: <20120215224221.22050.80605.stgit@zurg> <alpine.LSU.2.00.1202151815180.19722@eggly.anvils> <4F3C8B67.6090500@openvz.org> <alpine.LSU.2.00.1202161235430.2269@eggly.anvils> <alpine.LSU.2.00.1202171803380.25191@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1202171803380.25191@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hugh Dickins wrote:
> On Thu, 16 Feb 2012, Hugh Dickins wrote:
>>
>> Yours are not the only patches I was testing in that tree, I tried to
>> gather several other series which I should be reviewing if I ever have
>> time: Kamezawa-san's page cgroup diet 6, Xiao Guangrong's 4 prio_tree
>> cleanups, your 3 radix_tree changes, your 6 shmem changes, your 4 memcg
>> miscellaneous, and then your 15 books.
>>
>> The tree before your final 15 did well under pressure, until I tried to
>> rmdir one of the cgroups afterwards: then it crashed nastily, I'll have
>> to bisect into that, probably either Kamezawa's or your memcg changes.
>
> So far I haven't succeeded in reproducing that at all: it was real,
> but obviously harder to get than I assumed - indeed, no good reason
> to associate it with any of those patches, might even be in 3.3-rc.
>
> It did involve a NULL pointer dereference in mem_cgroup_page_lruvec(),
> somewhere below compact_zone() - but repercussions were causing the
> stacktrace to scroll offscreen, so I didn't get good details.

There some stupid bugs in my v1 patchset, it shouldn't works at all.
I did not expect that someone will try to use it. I sent it just to discuss.

Most destructive bug is this PageCgroupUsed() below:

+struct book *page_book(struct page *page)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct page_cgroup *pc;
+
+	if (mem_cgroup_disabled())
+		return &page_zone(page)->book;
+
+	pc = lookup_page_cgroup(page);
+	if (!PageCgroupUsed(pc))
+		return &page_zone(page)->book;
+	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
+	smp_rmb();
+	mz = mem_cgroup_zoneinfo(pc->mem_cgroup,
+			page_to_nid(page), page_zonenum(page));
+	return &mz->book;
+}

Thus after page uncharge I remove page from wrong book, under wrong lock =)

[ as I wrote, updated patchset there: https://github.com/koct9i/linux ]

>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
