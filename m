Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F0CBC3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:34:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3BE222DA9
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:34:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="EPfWbdLD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3BE222DA9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A21726B026E; Tue, 20 Aug 2019 09:34:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D1EF6B0270; Tue, 20 Aug 2019 09:34:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E8F56B0271; Tue, 20 Aug 2019 09:34:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0162.hostedemail.com [216.40.44.162])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6B66B026E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:34:20 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 17B0A8E56
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:34:20 +0000 (UTC)
X-FDA: 75842900280.10.rat43_8adb37bc8739
X-HE-Tag: rat43_8adb37bc8739
X-Filterd-Recvd-Size: 6161
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:34:19 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id u34so5991227qte.2
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:34:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=xkla8yZpkWsn7BQhjD5NVqgPEeC/v8sq4Q+tGQW7NAA=;
        b=EPfWbdLDIn9vYVNO92ekXg+Aqpk0N5AXlzR+0ptOOJgqHA7T2kwzvvGoWZuIvAfr/3
         0teKv2tf6kXm8zvOpJTZOgVyZgQEWvFiIxWu2cHJekpwmLDQC47QSg31UJZq5zb6Zu2R
         2IMDu+hVU12h9dIC7m/oQKnPEg4M1wIExBMafHRztS8uRKUSSBuZoFGd+3SaDkI6kpo9
         vvV6E/GjnRwfaJI3KJtUSJ1QIWuQ+GlNO4j01Dn9gcdYYIUQ/8xiMeu1LW4OuDyU/Q+B
         Nol5QsZWTj23vCJ3rkWepIYMWSEfA+1YPrUaB+2ZG3+Rn8BlPBDbWfse0wb2WYK0ODxI
         VHsw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=xkla8yZpkWsn7BQhjD5NVqgPEeC/v8sq4Q+tGQW7NAA=;
        b=fXQbCKTIaHzQiFBOQZqkzYWycMQaroAwVhL+VN8d6kMUK+OQ7UUo+T1jh5RAhCwAHm
         2TMtyeyJ+3K80TP8wIDzpy7GlMd6qcv56hwS3cWiXHrFUkqT39b3rgFqPURJ8sI5w6Vm
         a+xCC8AQArG7IvIYbh0kFIrrABm8v0nDePx9tWCKO2q3Bei0+yrkt+0+nWOVDngA69M+
         Z+pnQ4Kb+AW9TClrX6y7amaI2ta+1VqAeukxz+UkFZz3B1Mf3oq6SX+adTQwdl2ndgSi
         mAY1K3ugg8YjAUHryJeu+p81qY3vqatMMZDXUOOiJjorJCypjH5MI9/w+r1dNu65MZBF
         o04A==
X-Gm-Message-State: APjAAAVh0kAD7Wzv3HwWv2fsTF2RjfXMyzFTWLn+xuenx8cIdCcIwa0l
	VkLL4sVkm+SAjD1mxBhdWGtgdA==
X-Google-Smtp-Source: APXvYqwFrEe87m5OQXGPINdZ2bSNi3jP/uT5gUvqjHoY/CkByObbCPrlNUFCkrMtjbnMymplA2SbCQ==
X-Received: by 2002:ac8:53d3:: with SMTP id c19mr26516722qtq.225.1566308058877;
        Tue, 20 Aug 2019 06:34:18 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a23sm2037193qtj.5.2019.08.20.06.34.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Aug 2019 06:34:18 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i04HC-0000ct-4x; Tue, 20 Aug 2019 10:34:18 -0300
Date: Tue, 20 Aug 2019 10:34:18 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/4] mm, notifier: Catch sleeping/blocking for !blockable
Message-ID: <20190820133418.GG29246@ziepe.ca>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-5-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190820081902.24815-5-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.9.4 (2018-02-28)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 10:19:02AM +0200, Daniel Vetter wrote:
> We need to make sure implementations don't cheat and don't have a
> possible schedule/blocking point deeply burried where review can't
> catch it.
>=20
> I'm not sure whether this is the best way to make sure all the
> might_sleep() callsites trigger, and it's a bit ugly in the code flow.
> But it gets the job done.
>=20
> Inspired by an i915 patch series which did exactly that, because the
> rules haven't been entirely clear to us.
>=20
> v2: Use the shiny new non_block_start/end annotations instead of
> abusing preempt_disable/enable.
>=20
> v3: Rebase on top of Glisse's arg rework.
>=20
> v4: Rebase on top of more Glisse rework.
>=20
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Reviewed-by: Christian K=C3=B6nig <christian.koenig@amd.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
>  mm/mmu_notifier.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 538d3bb87f9b..856636d06ee0 100644
> +++ b/mm/mmu_notifier.c
> @@ -181,7 +181,13 @@ int __mmu_notifier_invalidate_range_start(struct m=
mu_notifier_range *range)
>  	id =3D srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist=
) {
>  		if (mn->ops->invalidate_range_start) {
> -			int _ret =3D mn->ops->invalidate_range_start(mn, range);
> +			int _ret;
> +
> +			if (!mmu_notifier_range_blockable(range))
> +				non_block_start();
> +			_ret =3D mn->ops->invalidate_range_start(mn, range);
> +			if (!mmu_notifier_range_blockable(range))
> +				non_block_end();

If someone Acks all the sched changes then I can pick this for
hmm.git, but I still think the existing pre-emption debugging is fine
for this use case.

Also, same comment as for the lockdep map, this needs to apply to the
non-blocking range_end also.

Anyhow, since this series has conflicts with hmm.git it would be best
to flow through the whole thing through that tree. If there are no
remarks on the first two patches I'll grab them in a few days.

Regards,
Jason

