Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFD0D6B0261
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 05:56:37 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r63so5032029wmb.9
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 02:56:37 -0800 (PST)
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id 11si6220674wmu.187.2017.12.22.02.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 02:56:36 -0800 (PST)
Received: from smtp02.buh.bitdefender.net (smtp.bitdefender.biz [10.17.80.76])
	by mx-sr.buh.bitdefender.com (Postfix) with ESMTP id 1A7227FBD1
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 12:01:23 +0200 (EET)
From: alazar@bitdefender.com
Subject: Re: [RFC PATCH v4 07/18] kvm: page track: add support for preread,
 prewrite and preexec
In-Reply-To: <a2058c71-dd43-c681-85bd-6ce0e68a9d1d@oracle.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
	<20171218190642.7790-8-alazar@bitdefender.com>
	<a2058c71-dd43-c681-85bd-6ce0e68a9d1d@oracle.com>
Date: Fri, 22 Dec 2017 12:01:43 +0200
Message-ID: <1513936903.Bee9A75.19685@host>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Patrick Colp <patrick.colp@oracle.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>, Xiao Guangrong <xiaoguangrong.eric@gmail.com>, Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>

On Thu, 21 Dec 2017 17:01:02 -0500, Patrick Colp <patrick.colp@oracle.com> wrote:
> On 2017-12-18 02:06 PM, Adalber LazA?r wrote:
> > From: Adalbert Lazar <alazar@bitdefender.com>
> > 
> > These callbacks return a boolean value. If false, the emulation should
> > stop and the instruction should be reexecuted in guest. The preread
> > callback can return the bytes needed by the read operation.
> > 
> > The kvm_page_track_create_memslot() was extended in order to track gfn-s
> > as soon as the memory slots are created.
> > 
> > +/*
> > + * Notify the node that an instruction is about to be executed.
> > + * Returning false doesn't stop the other nodes from being called,
> > + * but it will stop the emulation with ?!.
> 
> With what?
> 
> > +bool kvm_page_track_preexec(struct kvm_vcpu *vcpu, gpa_t gpa)
> > +{
> 
> Patrick

With X86EMUL_RETRY_INSTR, or some return value, depending on the context.

Currently, we call this function when the instruction is fetched, to
give the introspection tool more options. Depending on its policies,
the introspector could:
 - skip the instruction (and retry to guest)
 - remove the tracking for the "current" page (and retry to guest)
 - change the instruction (and continue the emulation)
 - do nothing but log (and continue the emulation)

Thanks for spotting this,
Adalbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
