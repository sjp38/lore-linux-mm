Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 993F56B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 00:06:35 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 85ADC3EE0AE
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:06:33 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6ADB945DE52
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:06:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 55DF845DE4D
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:06:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4655C1DB8038
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:06:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F05001DB803C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 13:06:32 +0900 (JST)
Message-ID: <4FEBD7C0.7090906@jp.fujitsu.com>
Date: Thu, 28 Jun 2012 13:04:16 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
References: <2a1a74bf-fbb5-4a6e-b958-44fff8debff2@zmail13.collab.prod.int.phx2.redhat.com> <34bb8049-8007-496c-8ffb-11118c587124@zmail13.collab.prod.int.phx2.redhat.com> <20120627154827.GA4420@tiehlicka.suse.cz> <alpine.DEB.2.00.1206271256120.22162@chino.kir.corp.google.com> <20120627200926.GR15811@google.com> <alpine.DEB.2.00.1206271316070.22162@chino.kir.corp.google.com> <20120627202430.GS15811@google.com>
In-Reply-To: <20120627202430.GS15811@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

(2012/06/28 5:24), Tejun Heo wrote:
> Hello,
>
> On Wed, Jun 27, 2012 at 01:21:27PM -0700, David Rientjes wrote:
>> Well it also has a prerequisite that memcg doesn't have: CONFIG_SWAP, so
>
> Right.
>
>> even if CONFIG_CGROUP_MEM_RES_CTLR_SWAP is folded into
>> CONFIG_CGROUP_MEM_RES_CTLR, then these should still depend on CONFIG_SWAP
>> since configuring them would imply there is some limit to be enforced.
>>
>> But to answer your question:
>>
>>     text	   data	    bss	    dec	    hex	filename
>>    25777	   3644	   4128	  33549	   830d	memcontrol.o.swap_disabled
>>    27294	   4476	   4128	  35898	   8c3a	memcontrol.o.swap_enabled
>
> I still wish it's folded into CONFIG_MEMCG and conditionalized just on
> CONFIG_SWAP tho.
>

In old days, memsw controller was not very stable. So, we devided the config.
And, it makes size of memory for swap-device double (adds 2bytes per swapent.)
That is the problem.

>> Is it really too painful to not create these files when
>> CONFIG_CGROUP_MEM_RES_CTLR_SWAP is disabled?  If so, can we at least allow
>> them to be opened but return -EINVAL if memory.memsw.limit_in_bytes is
>> written?
>
> Not at all, that was the first version anyway, which (IIRC) KAME
> didn't like and suggested always creating those files.  KAME, what do
> you think?
>

IIRC...at that time, we made decision, cgroup has no feature to
'create files dynamically'. Then, we made it in static, decision was done
at compile time and ignores "do_swap_account".

Now, IIUC, we have the feature. So, it's may be a time to create the file
with regard to "do_swap_account", making decision at boot time.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
