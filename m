Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D752C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:19:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C773220644
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 14:19:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C773220644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 755476B0003; Tue, 13 Aug 2019 10:19:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7056F6B0006; Tue, 13 Aug 2019 10:19:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F5446B0007; Tue, 13 Aug 2019 10:19:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0170.hostedemail.com [216.40.44.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD5A6B0003
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 10:19:27 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id E21282C2A
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:19:26 +0000 (UTC)
X-FDA: 75817612332.27.ghost92_8ca4567dd8e1b
X-HE-Tag: ghost92_8ca4567dd8e1b
X-Filterd-Recvd-Size: 2634
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com [91.199.104.161])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 14:19:26 +0000 (UTC)
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id A4E1130644BA;
	Tue, 13 Aug 2019 17:19:24 +0300 (EEST)
Received: from localhost (unknown [195.210.5.22])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 8DF49303EF04;
	Tue, 13 Aug 2019 17:19:24 +0300 (EEST)
From: Adalbert =?iso-8859-2?b?TGF643I=?= <alazar@bitdefender.com>
Subject: Re: [RFC PATCH v6 13/92] kvm: introspection: make the vCPU wait even
 when its jobs list is empty
To: Paolo Bonzini <pbonzini@redhat.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Radim =?iso-8859-2?b?S3LobeH4?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk
	<konrad.wilk@oracle.com>, Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	Samuel =?iso-8859-1?q?Laur=E9n?= <samuel.lauren@iki.fi>, Patrick Colp
	<patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, Weijiang Yang
	<weijiang.yang@intel.com>, Yu C Zhang <yu.c.zhang@intel.com>,
	Mihai =?UTF-8?b?RG9uyJt1?= <mdontu@bitdefender.com>
In-Reply-To: <c82b509a-86a7-6c2c-943e-f78a02e6efb1@redhat.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
	<20190809160047.8319-14-alazar@bitdefender.com>
	<c82b509a-86a7-6c2c-943e-f78a02e6efb1@redhat.com>
Date: Tue, 13 Aug 2019 17:19:51 +0300
Message-ID: <1565705991.C24cA0eF.26375.@15f23d3a749365d981e968181cce585d2dcb3ffa>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Aug 2019 10:43:52 +0200, Paolo Bonzini <pbonzini@redhat.com> w=
rote:
> On 09/08/19 17:59, Adalbert Laz=C4=83r wrote:
> > +void kvmi_handle_requests(struct kvm_vcpu *vcpu)
> > +{
> > +	struct kvmi *ikvm;
> > +
> > +	ikvm =3D kvmi_get(vcpu->kvm);
> > +	if (!ikvm)
> > +		return;
> > +
> > +	for (;;) {
> > +		int err =3D kvmi_run_jobs_and_wait(vcpu);
> > +
> > +		if (err)
> > +			break;
> > +	}
> > +
> > +	kvmi_put(vcpu->kvm);
> > +}
> > +
>=20
> Using kvmi_run_jobs_and_wait from two places (here and kvmi_send_event)
> is very confusing.  Does kvmi_handle_requests need to do this, or can i=
t
> just use kvmi_run_jobs?

I think I've added this wait to block vCPUs during single-step.
A 'wait_until_single_step_finished' job will do, I guess, so we could
use kvmi_run_jobs() here.

