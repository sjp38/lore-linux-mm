Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp06.au.ibm.com (8.13.8/8.13.6) with ESMTP id kAALXGcx7618700
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 20:33:17 -0100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAA9ZuKt059556
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 20:35:57 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAA9WUoF007945
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 20:32:30 +1100
Message-ID: <45544723.4030503@in.ibm.com>
Date: Fri, 10 Nov 2006 15:02:19 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 7/8] RSS controller fix resource groups parsing
References: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com> <20061109193627.21437.88058.sendpatchset@balbir.in.ibm.com> <455442B6.30800@openvz.org>
In-Reply-To: <455442B6.30800@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@openvz.org>
Cc: Linux MM <linux-mm@kvack.org>, dev@openvz.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

Pavel Emelianov wrote:
> Balbir Singh wrote:
>> echo adds a "\n" to the end of a string. When this string is copied from
>> user space, we need to remove it, so that match_token() can parse
>> the user space string correctly
>>
>> Signed-off-by: Balbir Singh <balbir@in.ibm.com>
>> ---
>>
>>  kernel/res_group/rgcs.c |    6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff -puN kernel/res_group/rgcs.c~container-res-groups-fix-parsing kernel/res_group/rgcs.c
>> --- linux-2.6.19-rc2/kernel/res_group/rgcs.c~container-res-groups-fix-parsing	2006-11-09 23:08:10.000000000 +0530
>> +++ linux-2.6.19-rc2-balbir/kernel/res_group/rgcs.c	2006-11-09 23:08:10.000000000 +0530
>> @@ -241,6 +241,12 @@ ssize_t res_group_file_write(struct cont
>>  	}
>>  	buf[nbytes] = 0;	/* nul-terminate */
>>  
>> +	/*
>> +	 * Ignore "\n". It might come in from echo(1)
> 
> Why not inform user he should call echo -n?

Yes, but what if the user does not use it? We can't afford to do the
wrong thing. But it's a good point, I'll document and recommend that
the users use echo -n.


> 
>> +	 */
>> +	if (buf[nbytes - 1] == '\n')
>> +		buf[nbytes - 1] = 0;
>> +
>>  	container_manage_lock();
>>  
>>  	if (container_is_removed(cont)) {
>> _
>>
> 
> That's the same patch as in [PATCH 1/8] mail. Did you attached
> a wrong one?

Yeah... I moved this patch from #7 to #1 and did not remove it.
Sorry!

-- 
	Thanks,
	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
