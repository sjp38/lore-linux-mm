Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD7C2806DF
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 10:30:29 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id n129so47103734pga.0
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 07:30:29 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10127.outbound.protection.outlook.com. [40.107.1.127])
        by mx.google.com with ESMTPS id k5si2316145pgh.227.2017.03.30.07.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 07:30:28 -0700 (PDT)
Subject: Re: [PATCH v2] module: check if memory leak by module.
References: <CGME20170329060315epcas5p1c6f7ce3aca1b2770c5e1d9aaeb1a27e1@epcas5p1.samsung.com>
 <1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
 <460c5798-1f4d-6fd0-cf32-349fbd605862@virtuozzo.com>
 <20170330133712.GA23946@amd>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <06383e49-148e-e31f-e66e-e50db7df470b@virtuozzo.com>
Date: Thu, 30 Mar 2017 17:31:45 +0300
MIME-Version: 1.0
In-Reply-To: <20170330133712.GA23946@amd>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Maninder Singh <maninder1.s@samsung.com>, jeyu@redhat.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, chris@chris-wilson.co.uk, joonas.lahtinen@linux.intel.com, mhocko@suse.com, keescook@chromium.org, jinb.park7@gmail.com, anisse@astier.eu, rafael.j.wysocki@intel.com, zijun_hu@htc.com, mingo@kernel.org, mawilcox@microsoft.com, thgarnie@google.com, joelaf@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pankaj.m@samsung.com, ajeet.y@samsung.com, hakbong5.lee@samsung.com, a.sahrawat@samsung.com, lalit.mohan@samsung.com, cpgs@samsung.com, Vaneet Narang <v.narang@samsung.com>



On 03/30/2017 04:37 PM, Pavel Machek wrote:
>  
>>  3) This might produce false positives. E.g. module may defer vfree() in workqueue, so the 
>>      actual vfree() call happens after module unloaded.
> 
> Umm. Really?
> 

I should have been more specific. I meant vfree() called by module from the interrupt context.
In that case the actual __vunmap() will be deferred via schedule_work() thus it might happen
after the module unloaded.
See 32fcfd40715e ("make vfree() safe to call from interrupt contexts")

> I agree that module may alloc memory and pass it to someone else. Ok
> so far.
> 

Right. In the case with vfree() from interrupt we actually pass the memory to
the core code to free it later. 

> But if module code executes after module is unloaded -- that is use
> after free -- right?

Sure, module code can't execute after module unloaded, it doesn't exist anymore.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
