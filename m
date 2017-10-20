Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E11536B0253
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 18:40:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 78so1175552wmb.15
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 15:40:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v194sor612389wmd.85.2017.10.20.15.40.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 15:40:29 -0700 (PDT)
Subject: Re: [PATCH 00/23] Hardened usercopy whitelisting
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <0ad1f8b1-3c9f-adb0-35c3-18619ff5aa25@redhat.com>
Date: Sat, 21 Oct 2017 00:40:25 +0200
MIME-Version: 1.0
In-Reply-To: <1497915397-93805-1-git-send-email-keescook@chromium.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com
Cc: David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 20/06/2017 01:36, Kees Cook wrote:
> 
> This updates the slab allocator to add annotations (useroffset and
> usersize) to define allowed usercopy regions. Currently, hardened
> usercopy performs dynamic bounds checking on whole slab cache objects.
> This is good, but still leaves a lot of kernel slab memory available to
> be copied to/from userspace in the face of bugs. To further restrict
> what memory is available for copying, this creates a way to whitelist
> specific areas of a given slab cache object for copying to/from userspace,
> allowing much finer granularity of access control. Slab caches that are
> never exposed to userspace can declare no whitelist for their objects,
> thereby keeping them unavailable to userspace via dynamic copy operations.
> (Note, an implicit form of whitelisting is the use of constant sizes
> in usercopy operations and get_user()/put_user(); these bypass hardened
> usercopy checks since these sizes cannot change at runtime.)

This breaks KVM completely on x86, due to two ioctls
(KVM_GET/SET_CPUID2) accessing the cpuid_entries field of struct
kvm_vcpu_arch.

There's also another broken ioctl, KVM_XEN_HVM_CONFIG, but it is
obsolete and not a big deal at all.

I can post some patches, but probably not until the beginning of
November due to travelling.  Please do not send this too close to the
beginning of the merge window.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
