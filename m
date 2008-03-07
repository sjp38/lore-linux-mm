Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m274gb78014459
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 15:42:37 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m274kq1q212162
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 15:46:52 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m274hGtV015643
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 15:43:17 +1100
Message-ID: <47D0C76D.8050207@linux.vnet.ibm.com>
Date: Fri, 07 Mar 2008 10:11:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot time
References: <20080306185952.23290.49571.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0803061108370.13110@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.0803061108370.13110@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Fri, 7 Mar 2008, Balbir Singh wrote:
> 
>> @@ -3010,3 +3020,16 @@ static void cgroup_release_agent(struct 
>>  	spin_unlock(&release_list_lock);
>>  	mutex_unlock(&cgroup_mutex);
>>  }
>> +
>> +static int __init cgroup_disable(char *str)
>> +{
>> +	int i;
>> +	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>> +		struct cgroup_subsys *ss = subsys[i];
>> +		if (!strcmp(str, ss->name)) {
>> +			ss->disabled = 1;
>> +			break;
>> +		}
>> +	}
>> +}
>> +__setup("cgroup_disable=", cgroup_disable);
> 
> This doesn't handle spaces very well, so isn't it possible for the name of 
> a current or future cgroup subsystem to be specified after cgroup_disable= 
> on the command line and have it disabled by accident?
> 

How do you distinguish that from the user wanting to disable the controller on
purpose? My understanding is that after parsing cgroup_disable=, the rest of the
text is passed to cgroup_disable to process further. You'll find that all the
__setup() code in the kernel is implemented this way.

>> diff -puN Documentation/kernel-parameters.txt~cgroup_disable Documentation/kernel-parameters.txt
>> --- linux-2.6.25-rc4/Documentation/kernel-parameters.txt~cgroup_disable	2008-03-06 17:57:32.000000000 +0530
>> +++ linux-2.6.25-rc4-balbir/Documentation/kernel-parameters.txt	2008-03-06 18:00:32.000000000 +0530
>> @@ -383,6 +383,10 @@ and is between 256 and 4096 characters. 
>>  	ccw_timeout_log [S390]
>>  			See Documentation/s390/CommonIO for details.
>>  
>> +	cgroup_disable= [KNL] Enable disable a particular controller
>> +			Format: {name of the controller}
>> +			See /proc/cgroups for a list of compiled controllers
>> +
> 
> This works on multiple controllers, though, if they follow 
> cgroup_disable=, so the documentation and format should reflect that.

Absolutely! done.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
