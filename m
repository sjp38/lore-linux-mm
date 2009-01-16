Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 141036B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 02:36:27 -0500 (EST)
Message-ID: <497038CD.8010505@cn.fujitsu.com>
Date: Fri, 16 Jan 2009 15:35:41 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] memcg: hierarchical reclaim by CSS ID
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>	<20090115192943.7c1df53a.kamezawa.hiroyu@jp.fujitsu.com>	<496FE30C.1090300@cn.fujitsu.com>	<20090116103810.5ef55cc3.kamezawa.hiroyu@jp.fujitsu.com>	<496FE791.9030208@cn.fujitsu.com> <20090116112211.ea4231aa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090116112211.ea4231aa.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

>>>>> +	while (!ret) {
>>>>> +		rcu_read_lock();
>>>>> +		nextid = root_mem->last_scanned_child + 1;
>>>>> +		css = css_get_next(&mem_cgroup_subsys, nextid, &root_mem->css,
>>>>> +				   &found);
>>>>> +		if (css && css_is_populated(css) && css_tryget(css))
>>>> I don't see why you need to check css_is_populated(css) ?
>>>>
>>> Main reason is for sanity. I don't like to hold css->refcnt of not populated css.
>> I think this is a rare case. It's just a very short period when a cgroup is
>> being created but not yet fully created.
>>
>>> Second reason is for avoinding unnecessary calls to try_to_free_pages(),
>>> it's heavy. I should also add mem->res.usage == 0 case for skipping but not yet.
>>>
>> And if mem->res.usage == 0 is checked, css_is_popuated() is just redundant.
>>
> Hmm ? Can I check mem->res.usage before css_tryget() ?
> 

I think you can. If css != NULL, css is valid (otherwise how can we access css->flags
in css_tryget), so mem is valid. Correct me if I'm wrong. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
