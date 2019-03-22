Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5135DC10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 08:22:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14BF021873
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 08:22:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14BF021873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A236D6B0003; Fri, 22 Mar 2019 04:22:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9ACCC6B0006; Fri, 22 Mar 2019 04:22:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E9B16B0007; Fri, 22 Mar 2019 04:22:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 591EB6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 04:22:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m31so624509edm.4
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 01:22:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gBzMpH9eoY2j46oXb5oa8zm2zu93w5b+vtsUdolkkbM=;
        b=LPPiKW5PxkLMP68VgszMseoPwwEjsrLQnNMpQC/7GB8GxVq6Rc+ymQ8VLh28vdsH9p
         U+ctFlf6stZs9VtRX9oKrKZdVXQRz8eLrVTSDindqN2Etg6ADiyNcB6/Cc6kTttclAoE
         nMx0UndSO6pRtMN1s/Dgj844TANPZJm6zyuwfG72qGbIbhfE4I94DO4xUnlU4EmR3PPi
         OvhAGvTZHRUN/USmHzK5rjAMcJJ5Ude50fuED1rbjnMs6R5mFGQ16t/9rCmikZzu/Aui
         PyWVzOnilWj8fBEoaPNadd5kUfuP/MAI5KMjocoPJYnIZTfLhE6xbiloRknTdfr34ziQ
         ge1g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXnGOrW6iiodbNbe37c7Jzf0z7Ld5qlRSuyzpGWj5ZhCR4KbBFf
	gg1fUk+NQHnu5ZJTKLHIQhxss894Jfis/8QlyXccItZgEPCnAuApTW2PeToppmuGHpsDKp4t/wE
	R9OjUAA6sPXj4EyU5wvME0flEK2y19RaKUjngfoHQTdi3SoGR43KIloGBz+R58ew=
X-Received: by 2002:a50:b6b8:: with SMTP id d53mr5355696ede.48.1553242957957;
        Fri, 22 Mar 2019 01:22:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5OBsxplzg0C1wPqrdH0nrdsipCwQP93RFrdj85JAPv7qfk+yS+qUITgnCSRekVxCXWOWM
X-Received: by 2002:a50:b6b8:: with SMTP id d53mr5355645ede.48.1553242956842;
        Fri, 22 Mar 2019 01:22:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553242956; cv=none;
        d=google.com; s=arc-20160816;
        b=jyGKbm3M+zKrjfcPz/ZlpDGFgbHWt5gLon1kflmucUQUzRwAoA0k6OTiW1dsbkVdlI
         U0hbQElJqy2rJ3RI6xPYdPOYJSYKKrueOfFItUkpj/QGMFexUqNOwsZxoyWMFgATtMlH
         iBhQw1MkfTm4X+EE+QlgXnLUEHvoTeOb3937hBDquloaqlT6yW/1dNOoVs0/DkldrSt2
         Fmg9EKhfuBDVpmbO0zZ5mw1hPyFSu5UInLMccJsdG4WDO/wCzMXg9eqg9EAtmoEr8Alg
         rHSABFksogRFHB+B819Qr9uayAEpaYrw21tNLXmaPK1tDfqUic36XGT9sKSYth6NHRiJ
         pkVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gBzMpH9eoY2j46oXb5oa8zm2zu93w5b+vtsUdolkkbM=;
        b=Ac1L9RFQh7R3V1uk7x6+0om4c6lQ8Le2V6DRQmuoaorFjkGd4xPaqIRbDEY1iU4x/b
         KCs1+uEYx8A5zcR1wezYZhW8x4ZhIib8Sa0JQ+j0dH1L2GB2XnJpUIyMYqOPB50T12sl
         ZTUc+epNO3wAy+dLqDlmXNrmzbDKeoQkSE9hqncoxSIDVonzMOUes7y8c5+H6++2oeWw
         VMk/wcSvpYF+ZvWxndkl7HdDkOgSVlwn+1htENYMJ7BtSXXd7RXJdW1PcZVbdwofuUdZ
         dmjxycOtZ+yLnqYJQV5CFIGveP534RHt/ZySGLXvua7uZR2OJlePoHleQkIoVOjs73mi
         2a0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si740092ejs.189.2019.03.22.01.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 01:22:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E8A59AEE5;
	Fri, 22 Mar 2019 08:22:35 +0000 (UTC)
Date: Fri, 22 Mar 2019 09:22:35 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>,
	osalvador@suse.de, anshuman.khandual@arm.com,
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [RESEND PATCH] mm/hotplug: fix notification in offline error path
Message-ID: <20190322082235.GA32418@dhcp22.suse.cz>
References: <20190320204255.53571-1-cai@lca.pw>
 <CAFqt6zbHwvTgFfrjvDbETRYu05O1W=_e_GT8R6pMkDhFfzYFOQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zbHwvTgFfrjvDbETRYu05O1W=_e_GT8R6pMkDhFfzYFOQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 22-03-19 12:20:12, Souptick Joarder wrote:
> On Thu, Mar 21, 2019 at 2:13 AM Qian Cai <cai@lca.pw> wrote:
> >
> > When start_isolate_page_range() returned -EBUSY in __offline_pages(), it
> > calls memory_notify(MEM_CANCEL_OFFLINE, &arg) with an uninitialized
> > "arg". As the result, it triggers warnings below. Also, it is only
> > necessary to notify MEM_CANCEL_OFFLINE after MEM_GOING_OFFLINE.
> 
> For my clarification, if test_pages_in_a_zone() failed in  __offline_pages(),
> we have the similar scenario as well. If yes, do we need to capture it
> in change log ?

Yes this is the same situation. We can add a note that the same applies
to test_pages_in_a_zone failure path but I do not think it is strictly
necessary. Thanks for the note anyway.
-- 
Michal Hocko
SUSE Labs

