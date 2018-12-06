Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2C486B7B9D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 14:20:58 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id m37so1372774qte.10
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 11:20:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v30si713984qtd.97.2018.12.06.11.20.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 11:20:57 -0800 (PST)
Date: Thu, 6 Dec 2018 14:20:51 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Message-ID: <20181206192050.GC3544@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <6e2a1dba-80a8-42bf-127c-2f5c2441c248@intel.com>
 <20181205001544.GR2937@redhat.com>
 <42006749-7912-1e97-8ccd-945e82cebdde@intel.com>
 <20181205021334.GB3045@redhat.com>
 <b3122fdf-02c3-2e9c-1da6-fb873b824d59@intel.com>
 <20181205175357.GG3536@redhat.com>
 <b8fab9a7-62ed-5d8d-3cb1-aea6aacf77fe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b8fab9a7-62ed-5d8d-3cb1-aea6aacf77fe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, linux-acpi@vger.kernel.org

On Thu, Dec 06, 2018 at 10:25:08AM -0800, Dave Hansen wrote:
> On 12/5/18 9:53 AM, Jerome Glisse wrote:
> > No so there is 2 kinds of applications:
> >     1) average one: i am using device {1, 3, 9} give me best memory for
> >        those devices
> ...
> > 
> > For case 1 you can pre-parse stuff but this can be done by helper library
> 
> How would that work?  Would each user/container/whatever do this once?
> Where would they keep the pre-parsed stuff?  How do they manage their
> cache if the topology changes?

Short answer i don't expect a cache, i expect that each program will have
a init function that query the topology and update the application codes
accordingly. This is what people do today, query all available devices,
decide which one to use and how, create context for each selected ones,
define a memory migration job/memory policy for each part of the program
so that memory is migrated/have proper policy in place when the code that
run on some device is executed.


Long answer:

I can not dictate how user folks do their program saddly :) I expect that
many application will do it once during start up. Then you will have all
those containers folks or VM folks that will get presure to react to hot-
plug. For instance if you upgrade your instance with your cloud provider
to have more GPUs or more TPUs ... It is likely to appear as an hotplug
from the VM/container point of view and thus as an hotplug from the
application point of view. So far demonstration i have seen do that by
relaunching the application ... More on that through the live re-patching
issues below.

Oh and i expect application will crash if you hot-unplug anything it is
using (this is what happens i believe now in most API). Again i expect
that some pressure from cloud user and provider will force programmer
to be a bit more reactive to this kind of event.


Live re-patching application code can be difficult i am told. Let say you
have:

void compute_serious0_stuff(accelerator_t *accelerator, void *inputA,
                            size_t sinputA, void *inputB, size_t sinputB,
                            void *outputA, size_t soutputA)
{
    ...

    // Migrate the inputA to the accelerator memory
    api_migrate_memory_to_accelerator(accelerator, inputA, sinputA);

    // The inputB buffer is fine in its default placement

    // The output is assume to be empty vma ie no page allocated yet
    // so set a policy to direct all allocation due to page fault to
    // use the accelerator memory
    api_set_memory_policy_to_accelerator(accelerator, outputA, soutputA);

    ...
    for_parallel<accelerator> (i = 0; i < THEYAREAMILLIONSITEMS; ++i) {
        // Do something serious
    }
    ...
}

void serious0_orchestrator(topology topology, void *inputA,
                           void *inputB, void *outputA)
{
    static accelerator_t **selected = NULL;
    static serious0_job_partition *partition;
    ...
    if (selected == NULL) {
        serious0_select_and_partition(topology, &selected, &partition,
                                      inputA, inputB, outputA)
    }
    ...
    for(i = 0; i < nselected; ++) {
        ...
        compute_serious0_stuff(selected[i],
                               inputA + partition[i].inputA_offset,
                               partition[i].inputA_size,
                               inputB + partition[i].inputB_offset,
                               partition[i].inputB_size,
                               outputA + partition[i].outputB_offset,
                               partition[i].outputA_size);
        ...
    }
    ...
    for(i = 0; i < nselected; ++) {
        accelerator_wait_finish(selected[i]);
    }
    ...
    // outputA is ready to be use by the next function in the program
}

If you start without a GPU/TPU your for_parallel will use the CPU and
with the code the compiler have emitted at built time. For GPU/TPU at
build time you compile your for_parallel loop to some intermediate
representation (a virtual ISA) then at runtime during the application
initialization that intermediate representation get lowered down to
all the available GPU/TPU on your system and each for_parallel loop
is patched to be turn into a call to:

void dispatch_accelerator_function(accelerator_t *accelerator,
                                   void *function, ...)
{
}

So in the above example the for_parallel loop becomes:
dispatch_accelerator_function(accelerator, i_compute_serious_stuff,
                              inputA, inputB, outputA);

This hot patching of code is easy to do when no CPU thread is running
the code. However when CPU threads are running it can be problematic,
i am sure you can do trickery like delay the patching only to the next
time the function get call by doing clever thing at build time like
prepending each for_parallel section with enough nop that would allow
you to replace it to a call to the dispatch function and a jump over
the normal CPU code.


I think compiler people want to solve the static case first ie during
application initializations decide what devices are gonna be use and
then update the application accordingly. But i expect it will grow
to support hotplug as relaunching the application is not that user
friendly even in this day an age where people starts millions of
container with one mouse click.


Anyway above example is how it looks today and accelerator can turn
up to be just regular CPU core if you do not have any devices. The
idea is that we would like a common API that cover both CPU thread
and device thread. Same for the migration/policy functions if it
happens that the accelerator is just plain old CPU then you want to
migrate memory to the CPU node and set memory policy to that node too.

Cheers,
J�r�me
