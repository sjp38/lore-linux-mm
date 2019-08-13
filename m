Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 797C7C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:01:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 423A8205F4
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 15:01:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 423A8205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C666A6B0003; Tue, 13 Aug 2019 11:01:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3CF46B0006; Tue, 13 Aug 2019 11:01:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2DBA6B0007; Tue, 13 Aug 2019 11:01:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0122.hostedemail.com [216.40.44.122])
	by kanga.kvack.org (Postfix) with ESMTP id 9345A6B0003
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 11:01:44 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2B5076114
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:01:44 +0000 (UTC)
X-FDA: 75817718928.05.C010D02
Received: from filter.hostedemail.com (10.5.16.251.rfc1918.com [10.5.16.251])
	by smtpin05.hostedemail.com (Postfix) with ESMTP id B076C18037D5B
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:01:31 +0000 (UTC)
X-HE-Tag: toes63_4754a2c1afe14
X-Filterd-Recvd-Size: 4291
Received: from mga18.intel.com (mga18.intel.com [134.134.136.126])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 15:01:29 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Aug 2019 08:01:28 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,381,1559545200"; 
   d="scan'208";a="351556260"
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.41])
  by orsmga005.jf.intel.com with ESMTP; 13 Aug 2019 08:01:28 -0700
Date: Tue, 13 Aug 2019 08:01:28 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>,
	kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?Q?Laur=E9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@vger.kernel.org,
	Yu C <yu.c.zhang@intel.com>,
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?iso-8859-1?Q?C=EErjaliu?= <mcirjaliu@bitdefender.com>
Subject: Re: [RFC PATCH v6 01/92] kvm: introduce KVMI (VM introspection
 subsystem)
Message-ID: <20190813150128.GB13991@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-2-alazar@bitdefender.com>
 <20190812202030.GB1437@linux.intel.com>
 <5d52a5ae.1c69fb81.5c260.1573SMTPIN_ADDED_BROKEN@mx.google.com>
 <5fa6bd89-9d02-22cd-24a8-479abaa4f788@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5fa6bd89-9d02-22cd-24a8-479abaa4f788@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 13, 2019 at 02:09:51PM +0200, Paolo Bonzini wrote:
> On 13/08/19 13:57, Adalbert Laz=C4=83r wrote:
> >> The refcounting approach seems a bit backwards, and AFAICT is driven=
 by
> >> implementing unhook via a message, which also seems backwards.  I as=
sume
> >> hook and unhook are relatively rare events and not performance criti=
cal,
> >> so make those the restricted/slow flows, e.g. force userspace to qui=
esce
> >> the VM by making unhook() mutually exclusive with every vcpu ioctl()=
 and
> >> maybe anything that takes kvm->lock.=20
> >>
> >> Then kvmi_ioctl_unhook() can use thread_stop() and kvmi_recv() just =
needs
> >> to check kthread_should_stop().
> >>
> >> That way kvmi doesn't need to be refcounted since it's guaranteed to=
 be
> >> alive if the pointer is non-null.  Eliminating the refcounting will =
clean
> >> up a lot of the code by eliminating calls to kvmi_{get,put}(), e.g.
> >> wrappers like kvmi_breakpoint_event() just check vcpu->kvmi, or mayb=
e
> >> even get dropped altogether.
> >=20
> > The unhook event has been added to cover the following case: while th=
e
> > introspection tool runs in another VM, both VMs, the virtual applianc=
e
> > and the introspected VM, could be paused by the user. We needed a way
> > to signal this to the introspection tool and give it time to unhook
> > (the introspected VM has to run and execute the introspection command=
s
> > during this phase). The receiving threads quits when the socket is cl=
osed
> > (by QEMU or by the introspection tool).

Why does closing the socket require destroying the kvmi object?  E.g. can
it be marked as defunct or whatever and only fully removed on a synchrono=
us
unhook from userspace?  Re-hooking could either require said unhook, or
maybe reuse the existing kvmi object with a new socket.

> > It's a bit unclear how, but we'll try to get ride of the refcount obj=
ect,
> > which will remove a lot of code, indeed.
>=20
> You can keep it for now.  It may become clearer how to fix it after the
> event loop is cleaned up.

By event loop, do you mean the per-vCPU jobs list?

