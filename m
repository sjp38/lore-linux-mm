Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 77DEE6B0389
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 18:58:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id r67so11668502pfr.6
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 15:58:49 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id m124si2566187pgm.123.2017.02.22.15.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 15:58:48 -0800 (PST)
Subject: Re: [HMM v17 00/14] HMM (Heterogeneous Memory Management) v17
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
 <20170222071915.GE9967@balbir.ozlabs.ibm.com>
 <20170222001603.162a1209efc06b6c46556383@linux-foundation.org>
 <CAKTCnzmA3B4r956GXv8UKxmCTqxdt=uoXr4KBbvzzfc=ciz03A@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f748e40a-04ff-9907-f25d-dfc8d4e5e7b7@nvidia.com>
Date: Wed, 22 Feb 2017 15:58:46 -0800
MIME-Version: 1.0
In-Reply-To: <CAKTCnzmA3B4r956GXv8UKxmCTqxdt=uoXr4KBbvzzfc=ciz03A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, haren@linux.vnet.ibm.com, Evgeny Baskakov <ebaskakov@nvidia.com>

On 02/22/2017 12:27 AM, Balbir Singh wrote:
> On Wed, Feb 22, 2017 at 7:16 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Wed, 22 Feb 2017 18:19:15 +1100 Balbir Singh <bsingharora@gmail.com> wrote:
>>>
>>> Andrew, do we expect to get this in 4.11/4.12? Just curious.
>>>
>>
>> I'll be taking a serious look after -rc1.
>>
>> The lack of reviewed-by, acked-by and tested-by is a concern.  It's
>> rather odd for a patchset in the 17th revision!  What's up with that?
>>
>> Have you reviewed or tested the patches?
>
> I reviewed v14/15 of the patches. Aneesh reviewed some versions as
> well. I know a few people who tested a small subset of the patches,
> I'll get them to report back as well. I think John Hubbard has been
> testing iterations as well. CC'ing other interested people as well
>
> Balbir
>

Yes, Evgeny Baskakov and I have been testing each of the posted versions. We are using both 
migration and mirroring, and have a small set of multi-threaded and multi-device tests. I've been 
procastinating about writing up a summary of the test results, partly because the patchset is still 
changing (bug fixes, new features, API changes) and so we keep resetting our testing.

We (ahem, actually Evgeny has done most of the work) have been debugging and proposing fixes 
directly to Jerome, and that email traffic with Jerome has not been CC-ing this list, so things have 
looked a little quieter than they really were.

Anyway, a very rudimentary testing report:

1. What we are testing: Our latest testing (in the last few weeks) has been against Jerome's repo, here:
	git://people.freedesktop.org/~glisse/linux (branch: hmm-next)

which has moved ahead from his hmm-v17 branch. hmm-next adds a few bug fixes, and a new feature 
(populating CPU pages on a GPU fault). Here are the differences in summary:

$ git diff --stat hmm-v17 hmm-next
  drivers/char/Kconfig             |   10 +
  drivers/char/Makefile            |    1 +
  drivers/char/hmm_dmirror.c       | 1168 +++++++++++++++++++++++++++++++++++++++++++++++++++++
  include/linux/migrate.h          |    8 +-
  include/uapi/linux/hmm_dmirror.h |   54 +++
  mm/hmm.c                         |    6 +-
  mm/migrate.c                     |  174 ++++++--
  7 files changed, 1388 insertions(+), 33 deletions(-)


2. API: As for the driver-kernel API: this is looking OK, although of course the documentation can 
be improved. As Jerome already explained, there are missing pieces functionality[1] that will be 
added later, and this may change the API, but for now, OK. With this initial API, we can handle both 
"device" and CPU page faults, and migrate pages around.

3. More testing plans: TODO: there are a lot of programs that can be easily modified, to use malloc 
instead of a special device-centric allocator. On our list.

4. Stability: still a little shaky, as we have some pretty recent bug fixes to try out.

5. Performance: I'll send out another note for that at some point. There was a performance bug that 
Jerome just recently fixed, and I want to see how it looks with that fix applied. No real surprises 
though.

6. Code reviews: the large size of the patchset, plus the requirement for a complicated driver to 
exercise it, makes it less likely for other people to review this patch series. It's a bit 
chicken-and-eggy, too, because our UVM driver can't be checked in and shipped until the kernel API 
stabilizes. heh.

-----

[1] For example, due to lacking file-backed memory support, some userspace program variables that 
are file-backed (initialized globals, etc) have to be mapped (from the device) instead of migrated 
to the device, on a device fault.

thanks,
john h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
