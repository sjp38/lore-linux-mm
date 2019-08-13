Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AA12C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:54:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 356D9206C2
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 13:54:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 356D9206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5C766B0003; Tue, 13 Aug 2019 09:54:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE4EC6B0006; Tue, 13 Aug 2019 09:54:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD34F6B0007; Tue, 13 Aug 2019 09:54:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0145.hostedemail.com [216.40.44.145])
	by kanga.kvack.org (Postfix) with ESMTP id 947C46B0003
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 09:54:18 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 528108248AA1
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:54:18 +0000 (UTC)
X-FDA: 75817548996.15.bee45_429eca6be0745
X-HE-Tag: bee45_429eca6be0745
X-Filterd-Recvd-Size: 3596
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 13:54:17 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id C2FFA305FFA2;
	Tue, 13 Aug 2019 16:54:15 +0300 (EEST)
Received: from localhost (unknown [195.210.5.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id AC1C7305B7A0;
	Tue, 13 Aug 2019 16:54:15 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 14/92] kvm: introspection: handle introspection
 commands before returning to guest
To: Paolo Bonzini <pbonzini@redhat.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk
	<konrad.wilk@oracle.com>, Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?q?Laur=E9n?= <samuel.lauren@iki.fi>, Patrick Colp
	<patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, Weijiang Yang
	<weijiang.yang@intel.com>, Yu C Zhang <yu.c.zhang@intel.com>,
	Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>,
	Mircea =?iso-8859-1?q?C=EErjaliu?= <mcirjaliu@bitdefender.com>
In-Reply-To: <645d86f5-67f6-f5d3-3fbb-5ee9898a7ef8@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-15-alazar@bitdefender.com>
	<645d86f5-67f6-f5d3-3fbb-5ee9898a7ef8@redhat.com>
Date: Tue, 13 Aug 2019 16:54:42 +0300
Message-ID: <1565704482.A9c6.22757.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019 10:26:29 +0200, Paolo Bonzini <pbonzini@redhat.com> w=
rote:
> On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> > +			prepare_to_swait_exclusive(&vcpu->wq, &wait,
> > +						   TASK_INTERRUPTIBLE);
> > +
> > +			if (kvm_vcpu_check_block(vcpu) < 0)
> > +				break;
> > +
> > +			waited =3D true;
> > +			schedule();
> > +
> > +			if (kvm_check_request(KVM_REQ_INTROSPECTION, vcpu)) {
> > +				do_kvmi_work =3D true;
> > +				break;
> > +			}
> > +		}
> > =20
> > -		waited =3D true;
> > -		schedule();
> > +		finish_swait(&vcpu->wq, &wait);
> > +
> > +		if (do_kvmi_work)
> > +			kvmi_handle_requests(vcpu);
> > +		else
> > +			break;
> >  	}
>=20
> Is this needed?  Or can it just go back to KVM_RUN and handle
> KVM_REQ_INTROSPECTION there (in which case it would be basically
> premature optimization)?
>=20

It might still be needed, unless we can get back to this function.

The original commit message for this change was this:

    kvm: do not abort kvm_vcpu_block() in order to handle KVMI requests
   =20
    Leaving kvm_vcpu_block() in order to handle a request such as 'pause'=
,
    would cause the vCPU to enter the guest when resumed. Most of the
    time this does not appear to be an issue, but during early boot it
    can happen for a non-boot vCPU to start executing code from areas tha=
t
    first needed to be set up by vCPU #0.
   =20
    In a particular case, vCPU #1 executed code which resided in an area
    not covered by a memslot, which caused an EPT violation that got
    turned in mmu_set_spte() into a MMIO request that required emulation.
    Unfortunatelly, the emulator tripped, exited to userspace and the VM
    was aborted.

