Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2398E6B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 17:45:06 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 9so252942050qkk.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:45:06 -0700 (PDT)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com. [209.85.220.179])
        by mx.google.com with ESMTPS id n51si1459424qtb.182.2017.03.13.14.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 14:45:05 -0700 (PDT)
Received: by mail-qk0-f179.google.com with SMTP id 1so233537869qkl.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:45:04 -0700 (PDT)
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
References: <20170303132949.GC31582@dhcp22.suse.cz>
 <cf383b9b-3cbc-0092-a071-f120874c053c@redhat.com>
 <20170306074258.GA27953@dhcp22.suse.cz>
 <20170306104041.zghsicrnadoap7lp@phenom.ffwll.local>
 <20170306105805.jsq44kfxhsvazkm6@sirena.org.uk>
 <20170306160437.sf7bksorlnw7u372@phenom.ffwll.local>
 <CA+M3ks77Am3Fx-ZNmgeM5tCqdM7SzV7rby4Es-p2F2aOhUco9g@mail.gmail.com>
 <26bc57ae-d88f-4ea0-d666-2c1a02bf866f@redhat.com>
 <CA+M3ks6R=n4n54wofK7pYcWoQKUhzyWQytBO90+pRDRrAhi3ww@mail.gmail.com>
 <20170313105433.GA12980@e106950-lin.cambridge.arm.com>
 <20170313132150.324h7em7c3iowmwj@sirena.org.uk>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <8ff814f9-3351-b164-e1e2-42f0dce456b6@redhat.com>
Date: Mon, 13 Mar 2017 14:45:00 -0700
MIME-Version: 1.0
In-Reply-To: <20170313132150.324h7em7c3iowmwj@sirena.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Brown <broonie@kernel.org>, Brian Starkey <brian.starkey@arm.com>
Cc: Benjamin Gaignard <benjamin.gaignard@linaro.org>, Michal Hocko <mhocko@kernel.org>, Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Rom Lemarchand <romlem@google.com>, devel@driverdev.osuosl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-mm@kvack.org

On 03/13/2017 06:21 AM, Mark Brown wrote:
> On Mon, Mar 13, 2017 at 10:54:33AM +0000, Brian Starkey wrote:
>> On Sun, Mar 12, 2017 at 02:34:14PM +0100, Benjamin Gaignard wrote:
> 
>>> Another point is how can we put secure rules (like selinux policy) on
>>> heaps since all the allocations
>>> go to the same device (/dev/ion) ? For example, until now, in Android
>>> we have to give the same
>>> access rights to all the process that use ION.
>>> It will become problem when we will add secure heaps because we won't
>>> be able to distinguish secure
>>> processes to standard ones or set specific policy per heaps.
>>> Maybe I'm wrong here but I have never see selinux policy checking an
>>> ioctl field but if that
>>> exist it could be a solution.
> 
>> I might be thinking of a different type of "secure", but...
> 
>> Should the security of secure heaps be enforced by OS-level
>> permissions? I don't know about other architectures, but at least on
>> arm/arm64 this is enforced in hardware; it doesn't matter who has
>> access to the ion heap, because only secure devices (or the CPU
>> running a secure process) is physically able to access the memory
>> backing the buffer.
> 3
>> In fact, in the use-cases I know of, the process asking for the ion
>> allocation is not a secure process, and so we wouldn't *want* to
>> restrict the secure heap to be allocated from only by secure
>> processes.
> 
> I think there's an orthogonal level of OS level security that can be
> applied here - it's reasonable for it to want to say things like "only
> processes that are supposed to be implementing functionality X should be
> able to try to allocate memory set aside for that functionality".  This
> mitigates against escallation attacks and so on, it's not really
> directly related to secure memory as such though.
> 

Ion also makes it pretty trivial to allocate large amounts of kernel
memory and possibly DoS the system. I'd like to have as little
policy in Ion as possible but more important would be a general
security review and people shouting "bad idea ahead".

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
