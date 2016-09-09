Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 30C1D6B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 11:40:31 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w193so193820837oiw.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 08:40:31 -0700 (PDT)
Received: from mail-it0-x234.google.com (mail-it0-x234.google.com. [2607:f8b0:4001:c0b::234])
        by mx.google.com with ESMTPS id v84si5068125iod.190.2016.09.09.08.40.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 08:40:30 -0700 (PDT)
Received: by mail-it0-x234.google.com with SMTP id c198so19647819ith.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 08:40:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5d5ef209-e005-12c6-9b34-1fdd21e1e6e2@linux.intel.com>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com> <CAPcyv4h5y4MHdXtdrdPRtG7L0_KCoxf_xwDGnHQ2r5yZoqkFzQ@mail.gmail.com>
 <5d5ef209-e005-12c6-9b34-1fdd21e1e6e2@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 9 Sep 2016 08:40:29 -0700
Message-ID: <CAPcyv4ibiZG3SkW0TZywn8Qovo3hpxBqs4wCfw1DFEbbE=1-Mg@mail.gmail.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in /proc/self/smaps)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gleb Natapov <gleb@kernel.org>, mtosatti@redhat.com, KVM list <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Hajnoczi <stefanha@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Sep 9, 2016 at 1:55 AM, Xiao Guangrong
<guangrong.xiao@linux.intel.com> wrote:
[..]
>>
>> Whether a persistent memory mapping requires an msync/fsync is a
>> filesystem specific question.  This mincore proposal is separate from
>> that.  Consider device-DAX for volatile memory or mincore() called on
>> an anonymous memory range.  In those cases persistence and filesystem
>> metadata are not in the picture, but it would still be useful for
>> userspace to know "is there page cache backing this mapping?" or "what
>> is the TLB geometry of this mapping?".
>
>
> I got a question about msync/fsync which is beyond the topic of this thread
> :)
>
> Whether msync/fsync can make data persistent depends on ADR feature on
> memory
> controller, if it exists everything works well, otherwise, we need to have
> another
> interface that is why 'Flush hint table' in ACPI comes in. 'Flush hint
> table' is
> particularly useful for nvdimm virtualization if we use normal memory to
> emulate
> nvdimm with data persistent characteristic (the data will be flushed to a
> persistent storage, e.g, disk).
>
> Does current PMEM programming model fully supports 'Flush hint table'? Is
> userspace allowed to use these addresses?

If you publish flush hint addresses in the virtual NFIT the guest VM
will write to them whenever a REQ_FLUSH or REQ_FUA request is sent to
the virtual /dev/pmemX device.  Yes, seems straightforward to take a
VM exit on those events and flush simulated pmem to persistent
storage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
