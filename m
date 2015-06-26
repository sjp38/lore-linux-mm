Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id 873336B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 04:56:36 -0400 (EDT)
Received: by yhnv31 with SMTP id v31so40444706yhn.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 01:56:36 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id b185si12668287ywd.207.2015.06.26.01.56.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 01:56:35 -0700 (PDT)
Message-ID: <558D13BF.9030907@citrix.com>
Date: Fri, 26 Jun 2015 09:56:31 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCHv1 6/8] xen/balloon: only hotplug additional
 memory if required
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
	<1435252263-31952-7-git-send-email-david.vrabel@citrix.com>
 <20150625211834.GO14050@olila.local.net-space.pl>
In-Reply-To: <20150625211834.GO14050@olila.local.net-space.pl>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <daniel.kiper@oracle.com>, David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org

On 25/06/15 22:18, Daniel Kiper wrote:
> On Thu, Jun 25, 2015 at 06:11:01PM +0100, David Vrabel wrote:
>> Now that we track the total number of pages (included hotplugged
>> regions), it is easy to determine if more memory needs to be
>> hotplugged.
>>
>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>> ---
>>  drivers/xen/balloon.c |   16 +++++++++++++---
>>  1 file changed, 13 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
>> index 960ac79..dd41da8 100644
>> --- a/drivers/xen/balloon.c
>> +++ b/drivers/xen/balloon.c
>> @@ -241,12 +241,22 @@ static void release_memory_resource(struct resource *resource)
>>   * bit set). Real size of added memory is established at page onlining stage.
>>   */
>>
>> -static enum bp_state reserve_additional_memory(long credit)
>> +static enum bp_state reserve_additional_memory(void)
>>  {
>> +	long credit;
>>  	struct resource *resource;
>>  	int nid, rc;
>>  	unsigned long balloon_hotplug;
>>
>> +	credit = balloon_stats.target_pages - balloon_stats.total_pages;
>> +
>> +	/*
>> +	 * Already hotplugged enough pages?  Wait for them to be
>> +	 * onlined.
>> +	 */
> 
> Comment is wrong or at least misleading. Both values does not depend on onlining.

If we get here and credit <=0 then the balloon is empty and we have
already hotplugged enough sections to reach target.  We need to wait for
userspace to online the sections that already exist.

>> +	if (credit <= 0)
>> +		return BP_EAGAIN;
> 
> Not BP_EAGAIN for sure. It should be BP_DONE but then balloon_process() will go
> into loop until memory is onlined at least up to balloon_stats.target_pages.
> BP_ECANCELED does work but it is misleading because it is not an error. So, maybe
> we should introduce BP_STOP (or something like that) which works like BP_ECANCELED
> and is not BP_ECANCELED.

We don't want to spin while waiting for userspace to online a new
section so BP_EAGAIN is correct here as it causes the balloon process to
be rescheduled at a later time.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
