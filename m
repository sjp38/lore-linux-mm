Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2486B0253
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 02:36:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 128so111899382pfb.2
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 23:36:53 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id di8si20076635pad.232.2016.09.11.23.36.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Sep 2016 23:36:52 -0700 (PDT)
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com>
 <CAPcyv4h5y4MHdXtdrdPRtG7L0_KCoxf_xwDGnHQ2r5yZoqkFzQ@mail.gmail.com>
 <5d5ef209-e005-12c6-9b34-1fdd21e1e6e2@linux.intel.com>
 <E987E30D-5C68-420C-B68D-7E0AAA7F2303@intel.com>
From: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Message-ID: <b7b3955f-a879-e75f-fda8-f5962a5d58ec@linux.intel.com>
Date: Mon, 12 Sep 2016 14:31:06 +0800
MIME-Version: 1.0
In-Reply-To: <E987E30D-5C68-420C-B68D-7E0AAA7F2303@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rudoff, Andy" <andy.rudoff@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gleb Natapov <gleb@kernel.org>, "mtosatti@redhat.com" <mtosatti@redhat.com>, KVM list <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Hajnoczi <stefanha@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>



On 09/12/2016 11:44 AM, Rudoff, Andy wrote:
>> Whether msync/fsync can make data persistent depends on ADR feature on
>> memory controller, if it exists everything works well, otherwise, we need
>> to have another interface that is why 'Flush hint table' in ACPI comes
>> in. 'Flush hint table' is particularly useful for nvdimm virtualization if
>> we use normal memory to emulate nvdimm with data persistent characteristic
>> (the data will be flushed to a persistent storage, e.g, disk).
>>
>> Does current PMEM programming model fully supports 'Flush hint table'? Is
>> userspace allowed to use these addresses?
>
> The Flush hint table is NOT a replacement for ADR.  To support pmem on
> the x86 architecture, the platform is required to ensure that a pmem
> store flushed from the CPU caches is in the persistent domain so that the
> application need not take any additional steps to make it persistent.
> The most common way to do this is the ADR feature.
>
> If the above is not true, then your x86 platform does not support pmem.

Understood.

However, virtualization is a special case as we can use normal memory
to emulate NVDIMM for the vm so that vm can bypass local file-cache,
reduce memory usage and io path, etc. Currently, this usage is useful
for lightweight virtualization, such as clean container.

Under this case, ADR is available on physical platform but it can
not help us to make data persistence for the vm. So that virtualizeing
'flush hint table' is a good way to handle it based on the acpi spec:
| software can write to any one of these Flush Hint Addresses to
| cause any preceding writes to the NVDIMM region to be flushed
| out of the intervening platform buffers 1 to the targeted NVDIMM
| (to achieve durability)

>
> Flush hints are for use by the BIOS and drivers and are not intended to
> be used in user space.  Flush hints provide two things:
>
> First, if a driver needs to write to command registers or movable windows
> on a DIMM, the Flush hint (if provided in the NFIT) is required to flush
> the command to the DIMM or ensure stores done through the movable window
> are complete before moving it somewhere else.
>
> Second, for the rare case where the kernel wants to flush stores to the
> smallest possible failure domain (i.e. to the DIMM even though ADR will
> handle flushing it from a larger domain), the flush hints provide a way
> to do this.  This might be useful for things like file system journals to
> help ensure the file system is consistent even in the face of ADR failure.

We are assuming ADR can fail, however, do we have a way to know whether
ADR works correctly? Maybe MCE can work on it?

This is necessary to support making data persistent without 'fsync/msync'
in userspace. Or do we need to unconditionally use 'flush hint address'
if it is available as current nvdimm driver does?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
