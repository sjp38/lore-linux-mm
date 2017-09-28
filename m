Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4F0BA6B0038
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 08:17:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f4so2064965wmh.7
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 05:17:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 32si1362782wri.174.2017.09.28.05.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 05:17:34 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8SCFbpr005680
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 08:17:33 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2d8vvqnfv6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 08:17:33 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 28 Sep 2017 13:17:31 +0100
Subject: Re: [PATCH v3 00/20] Speculative page faults
References: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
 <20170925163443.260d6092160ec704e2b04653@linux-foundation.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 28 Sep 2017 14:17:22 +0200
MIME-Version: 1.0
In-Reply-To: <20170925163443.260d6092160ec704e2b04653@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <d6ceae3b-09c0-0642-ff56-c31d044e805e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, "x86@kernel.org" <x86@kernel.org>

Hi,

On 26/09/2017 01:34, Andrew Morton wrote:
> On Mon, 25 Sep 2017 09:27:43 -0700 Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
>> On Mon, Sep 18, 2017 at 12:15 AM, Laurent Dufour
>> <ldufour@linux.vnet.ibm.com> wrote:
>>> Despite the unprovable lockdep warning raised by Sergey, I didn't get any
>>> feedback on this series.
>>>
>>> Is there a chance to get it moved upstream ?
>>
>> what is the status ?
>> We're eagerly looking forward for this set to land,
>> since we have several use cases for tracing that
>> will build on top of this set as discussed at Plumbers.
> 
> There has been sadly little review and testing so far :(

I do agree and I could just encourage people to do so :/

> I'll be taking a close look at it all over the next couple of weeks.

Thanks Andrew for giving it a close look.

> One terribly important thing (especially for a patchset this large and
> intrusive) is the rationale for merging it: the justification, usually
> in the form of end-user benefit.

The benefit is only for multi-threaded processes. But even on *small* 
systems with 16 CPUs, there is a real benefit.

> 
> Laurent's [0/n] provides some nice-looking performance benefits for
> workloads which are chosen to show performance benefits(!) but, alas,
> no quantitative testing results for workloads which we may suspect will
> be harmed by the changes(?).

I did test with kernbench, involving gcc/ld which are not 
multi-threaded, AFAIK, and I didn't see any impact.
But if you know additional test I should give a try, please advise.

Regarding ebizzy, it was designed to simulate web server's activity, so 
I guess there will be improvements when running real web servers.

>  Even things as simple as impact upon
> single-threaded pagefault-intensive workloads and its effect upon
> CONFIG_SMP=n .text size?
> 
> If you have additional usecases then please, spell them out for us in
> full detail so we can better understand the benefits which this
> patchset provides.

The other use-case I'm aware of is on memory database, where performance 
improvements is really significant, as I mentioned in the header of my 
series.

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
