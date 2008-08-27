Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7R1Gt3j029277
	for <linux-mm@kvack.org>; Wed, 27 Aug 2008 11:16:55 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7R1I2aw277910
	for <linux-mm@kvack.org>; Wed, 27 Aug 2008 11:18:02 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7R1I1tZ002819
	for <linux-mm@kvack.org>; Wed, 27 Aug 2008 11:18:02 +1000
Message-ID: <48B4AB47.7040209@linux.vnet.ibm.com>
Date: Wed, 27 Aug 2008 06:47:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/14]  delay page_cgroup freeing
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com> <20080822203324.409635c6.kamezawa.hiroyu@jp.fujitsu.com> <48B3ED0C.6050409@linux.vnet.ibm.com> <20080827085501.291f79b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080827085501.291f79b6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 26 Aug 2008 17:16:20 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>> +/*
>>> + * per-cpu slot for freeing page_cgroup in lazy manner.
>>> + * All page_cgroup linked to this list is OBSOLETE.
>>> + */
>>> +struct mem_cgroup_sink_list {
>>> +	int count;
>>> +	struct page_cgroup *next;
>>> +};
>> Can't we reuse the lru field in page_cgroup to build a list? Do we need them on
>> the memory controller LRU if they are obsolete? I want to do something similar
>> for both additions and deletions - reuse pagevec style, basically. I am OK,
>> having a list as well, in that case we can just reuse the LRU pointer.
>>
> reusing page_cgroup->lru is not a choice because this patch is for avoid
> locking on mz->lru_lock (and kfree).
> But using vector can be a choice. I'll try in the next version.

Kame,

Do we need to use the lru_lock? If we do an atomic check on PcgObsolete(), can't
we use another lock for obsolete pages and still use the lru list head?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
