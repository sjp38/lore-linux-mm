Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB4A8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 16:59:17 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id p4so2114422otl.10
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 13:59:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u186sor3027400oie.83.2018.12.20.13.59.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 13:59:15 -0800 (PST)
Subject: Re: Ipmi modules and linux-4.19.1
References: <CAJM9R-JWO1P_qJzw2JboMH2dgPX7K1tF49nO5ojvf=iwGddXRQ@mail.gmail.com>
 <20181220154217.GB2509588@devbig004.ftw2.facebook.com>
 <20181220160313.GB4170@linux.ibm.com> <20181220160408.GA23426@linux.ibm.com>
 <20181220160514.GD2509588@devbig004.ftw2.facebook.com>
 <20181220162225.GC4170@linux.ibm.com>
From: Corey Minyard <cminyard@mvista.com>
Message-ID: <76ae72b7-4dea-68c0-7d54-62055eec3ceb@mvista.com>
Date: Thu, 20 Dec 2018 15:59:14 -0600
MIME-Version: 1.0
In-Reply-To: <20181220162225.GC4170@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.ibm.com, Tejun Heo <tj@kernel.org>
Cc: Angel Shtilianov <angel.shtilianov@siteground.com>, linux-mm@kvack.org, dennis@kernel.org, cl@linux.com, jeyu@kernel.org

On 12/20/18 10:22 AM, Paul E. McKenney wrote:
> On Thu, Dec 20, 2018 at 08:05:14AM -0800, Tejun Heo wrote:
>> Hello,
>>
>> On Thu, Dec 20, 2018 at 08:04:08AM -0800, Paul E. McKenney wrote:
>>>> Yes, it is possible.  Just do something like this:
>>>>
>>>> 	struct srcu_struct my_srcu_struct;
>>>>
>>>> And before the first use of my_srcu_struct, do this:
>>>>
>>>> 	init_srcu_struct(&my_srcu_struct);
>>>>
>>>> This will result in alloc_percpu() being invoked to allocate the
>>>> needed per-CPU space.
>>>>
>>>> If my_srcu_struct is used in a module or some such, then to avoid memory
>>>> leaks, after the last use of my_srcu_struct, do this:
>>>>
>>>> 	cleanup_srcu_struct(&my_srcu_struct);
>>>>
>>>> There are several places in the kernel that take this approach.
>> Oops, my bad.  Somehow I thought the dynamic init didn't exist (I
>> checked the header but somehow completely skipped over them).  Thanks
>> for the explanation!
> No problem, especially given that if things go as they usually do, I
> will provide you ample opportunity to return the favor.  ;-)

Ok, I didn't realize that SRCU took up so much space.  It's true that 
this isn't
something that requires performance, but SRCU was awfully convenient to
use for this.

Unfortunately, it's not just a matter of adding the init_srcu_struct() 
to the
__init function.  I'm going to have to hunt down all the initial startup 
points
and add it there, and rework some of the other initialization code..  
But that's
something I can do.

Unless someone else would rather do it :-).

-corey
