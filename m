Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD8F2C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:44:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96A2925AE2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:44:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="XUEorjCr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96A2925AE2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 197766B0285; Thu, 30 May 2019 02:44:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 122236B0287; Thu, 30 May 2019 02:44:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00FDC6B0288; Thu, 30 May 2019 02:44:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC6116B0285
	for <linux-mm@kvack.org>; Thu, 30 May 2019 02:44:56 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id k22so3880384pfg.18
        for <linux-mm@kvack.org>; Wed, 29 May 2019 23:44:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=OtJUoXoSDr8VsqZMlQCV4tuhz5lMclRWprZBC+48UZI=;
        b=q0iSxbEEdqrQMyRzGw4gb8WCV0lljZon9rVYojwKilZgDtD08eR4X27XK8qHJpM5/Q
         AHg2tPIPBQT4Yn9fR3QT5QH3p/MlXq6Mlxt4moalKBYgcFIeI/17/u9RSR2M9qANbf3D
         9LTg0JIyyX5ieD5rTxtWVPF544jx0flveO4ctD0rSaSi6Jt5GnBuPKp1kaMluBgFPW+4
         NQYzalMCa8mRU0PxiY0DHweYiQuJUUap7GkH3LrYD0wnGTH64Cxz+HCxUiXD92NyI0FZ
         MbWd2OGG8qKm3b29hAC+oCOkQb4sCWusmDcvOI5ypJbRUy79HCPwEJ+NDKaerLH3VLpa
         xLCA==
X-Gm-Message-State: APjAAAVKsJopS/AAJI2CVOrG4trIVgcJRpGfU7F+LJnRJEG++J5NS4Ax
	/tzEQf8Im1e3ElEHlsaw+M8s3ff8EMzadsnfqeh9bEL/8O5rpUjnlOaA0C3oCeZIWTWRrZh9ezC
	GBLrJYvhXdAkWmTozIy4OGMRlGN/jHrl8LP+W+NN5Nv1iLkwfLglbhG4Od5M3UdVCnQ==
X-Received: by 2002:a65:6088:: with SMTP id t8mr2266722pgu.381.1559198696275;
        Wed, 29 May 2019 23:44:56 -0700 (PDT)
X-Received: by 2002:a65:6088:: with SMTP id t8mr2266687pgu.381.1559198695524;
        Wed, 29 May 2019 23:44:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559198695; cv=none;
        d=google.com; s=arc-20160816;
        b=nNoZXByeXPqL9ZMrFnjmEUFd2Mev3TGKNxggmUa1/0lpI6lTLiintDSuKhVZsyQ4QT
         qTDqDEgjd7X9S5AGEeC7xoX6XDyc3O1z2UV7i/hC6a1BXyiUV3mXToDzndhxrG3NpicO
         7qwSDVVRtQ3JT7CudzX42pA/kctiCyElPI9kfTkl5YHiXeb6SUH8BL+Z1tKCIVstr6FO
         Ez4ZDAM0QsrbqZSlzN1VBXH6VnufywyNE+Q91+dlFzVsEyCgd2R09+R2zZ4zPf3ZgKSI
         FIvSsJDAXfgX2gfeesYH2m3PC8P8GayH7Pspm0cSlPSn7Z4LEiYZbtho8b/P+AGSWzuM
         G1iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=OtJUoXoSDr8VsqZMlQCV4tuhz5lMclRWprZBC+48UZI=;
        b=t/gbL6nvEWuY6MmSFVsPOtjI79+zBmtDf/qfCzwpZXbkrhDBXr2IjPREhbHPAEVlTX
         e58FhqGbeoJIMlK0lrvkSxUZUMVjEJmUQc2qTc9MN5kJ43JdEi2RvgTkGsjVMps4Ly17
         s36x9PinnV5uRY6lS7hbaD/+pq+h4FSZGA8v/fjkopWiye1OAOHP/3YNOZDrA3w1nK9g
         p37Ya82+yNWo1m+C2fi9ezvoCAi8FQBG7Lt/oHfkrAvG91WO3gXtlxfZNJ/C2AYcj/Na
         0eR2tL22IVoRKNU1dIfrebtLKcumgqhVIeUTeXZmQsbnxped0MfVPJ9WlCx9L8aOu9ex
         WMGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=XUEorjCr;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f38sor414198pjg.13.2019.05.29.23.44.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 23:44:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=XUEorjCr;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=OtJUoXoSDr8VsqZMlQCV4tuhz5lMclRWprZBC+48UZI=;
        b=XUEorjCrLN9OrKuTIaR8sqQcataBFWGo19e2lBEQq/O74XS3Rv/gHEewD1Xhxg87dF
         Li12khbvVst/JlwygCiwvAhusNa3tSQFd4Sci5NEM5LIDG4i1O/IuqU4NCA4JrjyTjI5
         Z8e+mv6BlLgw2Wij6fVvKbwpyso+4TBaM01wI=
X-Google-Smtp-Source: APXvYqyoyOiL1g0uw5EVCPG0xAn0ze5ad3M0tRvk7mVR1v4xGNiEEXjkXPCgkCattXKsglAopRzh3g==
X-Received: by 2002:a17:90a:8089:: with SMTP id c9mr2007919pjn.68.1559198694988;
        Wed, 29 May 2019 23:44:54 -0700 (PDT)
Received: from localhost ([12.15.241.26])
        by smtp.gmail.com with ESMTPSA id x1sm1242193pgq.13.2019.05.29.23.44.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 29 May 2019 23:44:54 -0700 (PDT)
Date: Wed, 29 May 2019 23:44:53 -0700
From: Chris Down <chris@chrisdown.name>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-ID: <20190530064453.GA110128@chrisdown.name>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190530061221.GA6703@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190530061221.GA6703@dhcp22.suse.cz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko writes:
>Maybe I am missing something so correct me if I am wrong but the new
>calculation actually means that we always allow to scan even min
>protected memcgs right?

We check if the memcg is min protected as a precondition for coming into this 
function at all, so this generally isn't possible. See the mem_cgroup_protected 
MEMCG_PROT_MIN check in shrink_node.

(Of course, it's possible we race with going within protection thresholds 
again, but this patch doesn't make that any better or worse than the previous 
situation.)

