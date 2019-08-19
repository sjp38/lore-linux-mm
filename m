Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73425C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 18:52:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FABF214DA
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 18:52:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FABF214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC0016B0005; Mon, 19 Aug 2019 14:52:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6DD36B0006; Mon, 19 Aug 2019 14:52:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A34D76B000C; Mon, 19 Aug 2019 14:52:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0026.hostedemail.com [216.40.44.26])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD8C6B0005
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 14:52:43 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 16F93283E
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:52:43 +0000 (UTC)
X-FDA: 75840073806.27.fold77_6eec5a30f5826
X-HE-Tag: fold77_6eec5a30f5826
X-Filterd-Recvd-Size: 2940
Received: from mga18.intel.com (mga18.intel.com [134.134.136.126])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 18:52:42 +0000 (UTC)
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Aug 2019 11:52:40 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,405,1559545200"; 
   d="scan'208";a="172210414"
Received: from sjchrist-coffee.jf.intel.com (HELO linux.intel.com) ([10.54.74.41])
  by orsmga008.jf.intel.com with ESMTP; 19 Aug 2019 11:52:40 -0700
Date: Mon, 19 Aug 2019 11:52:40 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
To: Adalbert =?utf-8?B?TGF6xINy?= <alazar@bitdefender.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
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
	Mihai =?utf-8?B?RG9uyJt1?= <mdontu@bitdefender.com>
Subject: Re: [RFC PATCH v6 55/92] kvm: introspection: add KVMI_CONTROL_MSR
 and KVMI_EVENT_MSR
Message-ID: <20190819185240.GC1916@linux.intel.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-56-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190809160047.8319-56-alazar@bitdefender.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 07:00:10PM +0300, Adalbert Laz=C4=83r wrote:
> +int kvmi_arch_cmd_control_msr(struct kvm_vcpu *vcpu,
> +			      const struct kvmi_control_msr *req)
> +{
> +	int err;
> +
> +	if (req->padding1 || req->padding2)
> +		return -KVM_EINVAL;
> +
> +	err =3D msr_control(vcpu, req->msr, req->enable);
> +
> +	if (!err && req->enable)

This needs a comment explaining that it intentionally calls into arch
code only for the enable case so as to avoid having to deal with tracking
whether or not it's safe to disable interception.  At first (and second)
glance it look like KVM is silently ignoring the @enable=3Dfalse case.

> +		kvm_arch_msr_intercept(vcpu, req->msr, req->enable);

Renaming to kvm_arch_enable_msr_intercept() would also help communicate
that KVMI can't be used to disable msr interception.  The function can
always be renamed if someone takes on the task of enhancing the arch code
to handling disabling interception.

> +
> +	return err;
> +}

