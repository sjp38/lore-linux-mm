Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 69A666B0047
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 08:27:06 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n15DR3UW016466
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Feb 2009 22:27:04 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B4A2F45DE54
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:27:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 702DC45DE4D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:27:03 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D7E7E08006
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:27:03 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E162BE08001
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:27:02 +0900 (JST)
Message-ID: <19fabd2ab6062c563832d0caa85deaa7.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090205131741.GC6915@linux.vnet.ibm.com>
References: <20090205185959.7971dee4.kamezawa.hiroyu@jp.fujitsu.com>
    <20090205131741.GC6915@linux.vnet.ibm.com>
Date: Thu, 5 Feb 2009 22:27:02 +0900 (JST)
Subject: Re: [RFC][PATCH] Reduce size of swap_cgroup by CSS ID
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Paul E. McKenney wrote:
> On Thu, Feb 05, 2009 at 06:59:59PM +0900, KAMEZAWA Hiroyuki wrote:

>> +static struct mem_cgroup *mem_cgroup_lookup_get(unsigned short id)
>> +{
>> +	struct cgroup_subsys_state *css;
>> +
>> +	/* ID 0 is unused ID */
>> +	if (!id)
>> +		return NULL;
>> +	css = css_lookup(&mem_cgroup_subsys, id);
>> +	if (css && css_tryget(css))
>> +		return container_of(css, struct mem_cgroup, css);
>
> So css_tryget(), if successful, prevents the structure referenced by
> css from being freed, correct?  (If not, the range of the RCU read-side
> critical sections surrounding calls to mem_cgroup_lookup_get() must be
> extended.)
>
One reference to css by css_tryget() prevents rmdir(). So, css will
not be freed until css_put() is called.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
