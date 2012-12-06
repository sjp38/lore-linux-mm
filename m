Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A27406B009D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 11:40:06 -0500 (EST)
Message-ID: <1354811493.21116.10.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device
 operation
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 06 Dec 2012 09:31:33 -0700
In-Reply-To: <50C0C6E1.4000102@gmail.com>
References: 
	<1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	   <50B5EFE9.3040206@huawei.com>
	  <1354128096.26955.276.camel@misato.fc.hp.com> <50C0C13A.1040905@gmail.com>
	 <1354809803.21116.4.camel@misato.fc.hp.com> <50C0C6E1.4000102@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Hanjun Guo <guohanjun@huawei.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>

On Fri, 2012-12-07 at 00:25 +0800, Jiang Liu wrote:
> On 12/07/2012 12:03 AM, Toshi Kani wrote:
> > On Fri, 2012-12-07 at 00:00 +0800, Jiang Liu wrote:
> >> On 11/29/2012 02:41 AM, Toshi Kani wrote:
> >>> On Wed, 2012-11-28 at 19:05 +0800, Hanjun Guo wrote:
 : 
> >>> Yes, sharing idea is good. :)  I do not know if we need all 6 steps (I
> >>> have not looked at all your changes yet..), but in my mind, a hot-plug
> >>> operation should be composed with the following 3 phases.
> >>>
> >>> 1. Validate phase - Verify if the request is a supported operation.  All
> >>> known restrictions are verified at this phase.  For instance, if a
> >>> hot-remove request involves kernel memory, it is failed in this phase.
> >>> Since this phase makes no change, no rollback is necessary to fail.  
> >>>
> >>> 2. Execute phase - Perform hot-add / hot-remove operation that can be
> >>> rolled-back in case of error or cancel.
> >>>
> >>> 3. Commit phase - Perform the final hot-add / hot-remove operation that
> >>> cannot be rolled-back.  No error / cancel is allowed in this phase.  For
> >>> instance, eject operation is performed at this phase.  
> >> Hi Toshi,
> >> 	There are one more step needed. Linux provides sysfs interfaces to
> >> online/offline CPU/memory sections, so we need to protect from concurrent
> >> operations from those interfaces when doing physical hotplug. Think about
> >> following sequence:
> >> Thread 1
> >> 1. validate conditions for hot-removal
> >> 2. offline memory section A
> >> 3.						online memory section A			
> >> 4. offline memory section B
> >> 5 hot-remove memory device hosting A and B.
> > 
> > Hi Gerry,
> > 
> > I agree.  And I am working on a proposal that tries to address this
> > issue by integrating both sysfs and hotplug operations into a framework.
> Hi Toshi,
> 	But the sysfs for CPU and memory online/offline are platform independent
> interfaces, and the ACPI based hotplug is platform dependent interfaces. I'm not
> sure whether it's feasible to merge them. For example we still need offline interface
> to stop using faulty CPUs on platform without physical hotplug capabilities.
> 	We have solved this by adding a "busy" flag to the device, so the sysfs
> will just return -EBUSY if the busy flag is set.

I am making the framework code platform-independent so that it can
handle both cases.  Well, I am still prototyping, so hopefully it will
work. :)

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
