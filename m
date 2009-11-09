Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BF5186B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 02:19:16 -0500 (EST)
Message-ID: <4AF7C238.2080203@cn.fujitsu.com>
Date: Mon, 09 Nov 2009 15:18:16 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mmotm 1/8] cgroup: introduce cancel_attach()
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp> <20091106141106.a2bd995a.nishimura@mxp.nes.nec.co.jp> <20091109065759.GC3042@balbir.in.ibm.com>
In-Reply-To: <20091109065759.GC3042@balbir.in.ibm.com>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

>> @@ -1553,8 +1553,16 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>>  	for_each_subsys(root, ss) {
>>  		if (ss->can_attach) {
>>  			retval = ss->can_attach(ss, cgrp, tsk, false);
>> -			if (retval)
>> -				return retval;
>> +			if (retval) {
>> +				/*
>> +				 * Remember at which subsystem we've failed in
>> +				 * can_attach() to call cancel_attach() only
>> +				 * against subsystems whose attach() have
>> +				 * succeeded(see below).
>> +				 */
>> +				failed_ss = ss;
> 
> failed_ss is global? Is it a marker into an array of subsystems? Don't
> we need more than one failed_ss for each failed subsystem? Or do we
> find the first failed subsystem, cancel_attach and fail all
> migrations?
> 

The latter.

We record the first subsys that failed can_attach(), and break out
the for loop, and call cancel_attach() on those subsystems that
has succeeded in can_attach().

>> +				goto out;
>> +			}
>>  		}
>>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
