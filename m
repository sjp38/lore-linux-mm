Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3216B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 12:24:37 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id c67so255284847vkh.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 09:24:37 -0700 (PDT)
Received: from mail-yw0-x235.google.com (mail-yw0-x235.google.com. [2607:f8b0:4002:c05::235])
        by mx.google.com with ESMTPS id s203si9306693yws.61.2016.05.20.09.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 09:24:36 -0700 (PDT)
Received: by mail-yw0-x235.google.com with SMTP id j74so114112292ywg.1
        for <linux-mm@kvack.org>; Fri, 20 May 2016 09:24:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAmzW4PN4wcPWbjf=Hws2qN_eZC1HCmn-gQC9_DB5ek5+bNksQ@mail.gmail.com>
References: <1463594175-111929-1-git-send-email-thgarnie@google.com>
 <1463594175-111929-3-git-send-email-thgarnie@google.com> <alpine.DEB.2.20.1605181323260.14349@east.gentwo.org>
 <CAJcbSZFhsZheqdZ5FD8auhiu8ozCyq-0xY1wjYu3j+Wc2R8nGg@mail.gmail.com>
 <alpine.DEB.2.20.1605181401560.29313@east.gentwo.org> <CAJcbSZHwZxH=NN+xk7N+O-47QQHmRchgqMS5==_HzH1no5ho9g@mail.gmail.com>
 <20160519020722.GC10245@js1304-P5Q-DELUXE> <CAJcbSZGUTJdzRDno=+V+F4Yu_gaU_k0UJq5xhF5PPwgKGi3O7A@mail.gmail.com>
 <CAAmzW4PN4wcPWbjf=Hws2qN_eZC1HCmn-gQC9_DB5ek5+bNksQ@mail.gmail.com>
From: Thomas Garnier <thgarnie@google.com>
Date: Fri, 20 May 2016 09:24:35 -0700
Message-ID: <CAJcbSZGTxWHJpvcp8s=KQTX9my4rw9Gmg8KDs=ajj5BiqkJQcw@mail.gmail.com>
Subject: Re: [RFC v1 2/2] mm: SLUB Freelist randomization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Petr Mladek <pmladek@suse.com>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, kernel-hardening@lists.openwall.com

On Thu, May 19, 2016 at 7:15 PM, Joonsoo Kim <js1304@gmail.com> wrote:
> 2016-05-20 5:20 GMT+09:00 Thomas Garnier <thgarnie@google.com>:
>> I ran the test given by Joonsoo and it gave me these minimum cycles
>> per size across 20 usage:
>
> I can't understand what you did here. Maybe, it's due to my poor Engling.
> Please explain more. You did single thread test? Why minimum cycles
> rather than average?
>

I used your version of slab_test and ran it 20 times for each
versions. I compared
the minimum number of cycles as an optimal case for comparison. As you said
slab_test results can be unreliable. Comparing the average across multiple runs
always gave odd results.

>> size,before,after
>> 8,63.00,64.50 (102.38%)
>> 16,64.50,65.00 (100.78%)
>> 32,65.00,65.00 (100.00%)
>> 64,66.00,65.00 (98.48%)
>> 128,66.00,65.00 (98.48%)
>> 256,64.00,64.00 (100.00%)
>> 512,65.00,66.00 (101.54%)
>> 1024,68.00,64.00 (94.12%)
>> 2048,66.00,65.00 (98.48%)
>> 4096,66.00,66.00 (100.00%)
>
> It looks like performance of all size classes are the same?
>
>> I assume the difference is bigger if you don't have RDRAND support.
>
> What does RDRAND means? Kconfig? How can I check if I have RDRAND?
>

Sorry, I was referring to the usage of get_random_bytes_arch which
will be faster
if the test machine support specific instructions (like RDRAND).

>> Christoph, Joonsoo: Do you think it would be valuable to add a CONFIG
>> to disable additional randomization per new page? It will remove
>> additional entropy but increase performance for machines without arch
>> specific randomization instructions.
>
> I don't think that it deserve another CONFIG. If performance is a matter,
> I think that removing additional entropy is better until it is proved that
> entropy is a problem.
>

I will do more testing before the next RFC to decide the best approach.

> Thanks.

Thanks for the comments,
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
