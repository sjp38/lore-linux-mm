Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6A84F6B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 21:58:07 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id xk3so238380216obc.2
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 18:58:07 -0800 (PST)
Received: from alln-iport-1.cisco.com (alln-iport-1.cisco.com. [173.37.142.88])
        by mx.google.com with ESMTPS id o1si24590978oep.86.2016.02.15.18.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 18:58:06 -0800 (PST)
From: "Nag Avadhanam (nag)" <nag@cisco.com>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
Date: Tue, 16 Feb 2016 02:58:04 +0000
Message-ID: <D2E7B337.D5404%nag@cisco.com>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
 <20160214211856.GT19486@dastard> <56C216CA.7000703@cisco.com>
 <20160215230511.GU19486@dastard> <56C264BF.3090100@cisco.com>
 <20160216004531.GA28260@thunk.org>
In-Reply-To: <20160216004531.GA28260@thunk.org>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <8F6A8761ADCB2246BFAADE662A180BE7@emea.cisco.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, "Daniel Walker (danielwa)" <danielwa@cisco.com>
Cc: Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Jonathan Corbet <corbet@lwn.net>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

We have a class of platforms that are essentially swap-less embedded
systems that have limited memory resources (2GB and less).

There is a need to implement early alerts (before the OOM killer kicks in)
based on the current memory usage so admins can take appropriate steps (do
not initiate provisioning operations but support existing services,
de-provision certain services, etc. based on the extent of memory usage in
the system) .=20

There is also a general need to let end users know the available memory so
they can determine if they can enable new services (helps in planning).

These two depend upon knowing approximate (accurate within few 10s of MB)
memory usage within the system. We want to alert admins before system
exhibits any thrashing behaviors.

We find the source of accounting anomalies to be the page cache
accounting. Anonymous page accounting is fine. Page cache usage on our
system can be attributed to these =AD file system cache, shared memory stor=
e
(non-reclaimable) and the in-memory file systems (non-reclaimable). We
know the sizes of the shared memory stores and the in memory file system
sizes.

If we can determine the amount of reclaimable file system cache (+/- few
10s of MB), we can improve the serviceability of these systems.
=20
Total - (# of bytes of anon pages + # of bytes of shared memory/tmpfs
pages + # of bytes of non-reclaimable file system cache pages) gives us a
measure of the available memory.


Its the calculation of the # of bytes of non-reclaimable file system cache
pages that has been troubling us. We do not want to count inactive file
pages (of programs/binaries) that were once mapped by any process in the
system as reclaimable because that might lead to thrashing under memory
pressure (we want to alert admins before system starts dropping text
pages).

>From our experiments, we determined running a VM scan looking for
droppable pages came close to establishing that number. If there are
cheaper ways of determining this stat, please let us know.

Thanks,
nag=20


On 2/15/16, 4:45 PM, "Theodore Ts'o" <tytso@mit.edu> wrote:

>On Mon, Feb 15, 2016 at 03:52:31PM -0800, Daniel Walker wrote:
>> >>We need it to determine accurately what the free memory in the
>> >>system is. If you know where we can get this information already
>> >>please tell, we aren't aware of it. For instance /proc/meminfo isn't
>> >>accurate enough.
>>=20
>> Approximate point-in-time indication is an accurate characterization
>> of what we are doing. This is good enough for us. NO matter what we
>> do, we are never going to be able to address the "time of check to
>> time of use=B2 window.  But, this approximation works reasonably well
>> for our use case.
>
>Why do you need such accuracy, and what do you consider "good enough".
>Having something which iterates over all of the inodes in the system
>is something that really shouldn't be in a general production kernel
>At the very least it should only be accessible by root (so now only a
>careless system administrator can DOS attack the system) but the
>Dave's original question still stands.  Why do you need a certain
>level of accuracy regarding how much memory is available after
>dropping all of the caches?  What problem are you trying to
>solve/avoid?
>
>It may be that you are going about things completely the wrong way,
>which is why understanding the higher order problem you are trying to
>solve might be helpful in finding something which is safer,
>architecturally cleaner, and something that could go into the upstream
>kernel.
>
>Cheers,
>
>						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
