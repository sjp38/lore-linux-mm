Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86054C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:03:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42D83206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:03:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42D83206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7F1D8E0003; Wed, 31 Jul 2019 04:03:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A312A8E0001; Wed, 31 Jul 2019 04:03:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AB5C8E0003; Wed, 31 Jul 2019 04:03:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC478E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:03:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so41882488edc.6
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:03:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P5gAHFdYTTIUirtAf6BErUeidAjSkmDOewDij3+SGes=;
        b=OYsh44NvVONYC5ICZ35wGOi/+Ri0Fis1oRVnaP1i0simyMwvtwUxTcv5VoEYR0Vg1q
         Pe6F2r0j70jGVfWqfVQByeMyZ/IsF1lUCj6TOdhsCwk9q2JqA0xtR/zvZ0uyqSmWXcdF
         QpBEP9bqCCQOmE5+tOmxV36WBYoNlgb8V84DzToNh73jMb0WupynKSYwbeGLBh4WCZ8s
         wsHQVSzj8ClcL1JDG7V6VebzedakZndxwHkNhY3umK2R+aIe1+VTJ3g2igYlczWF23Ke
         +UKizMOwh2aAOdf0xP1h5xpPKAZNzshFdkNYwPQNi2KXLUGE73jpyyKcf6L5HJW8pWtp
         3M4A==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVrzhswy6j7MTpd2Q8LulWwhwedDg+vyAamlV+tXHbjq8+Mp7YL
	gBQpZqHaCGPzAklzW2nkNZ2YiVF47n53+bu/UUeI1/dw/j+BiIk8/Vd2tAMALToQTGMMNjJaazi
	rJAgEjEhUmyXQ/zzvlRzyLfN7a2nIpQmCB+nlTMo7HAFuDBROCIwaPWLUh9qDzIg=
X-Received: by 2002:a17:907:447e:: with SMTP id oo22mr73667889ejb.169.1564560192732;
        Wed, 31 Jul 2019 01:03:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaWUBB2VRi079xS6hTUFVgT3EsEqPjRT7Zbc/Ci3Joy3vDFwQr4eVBMAiteJUxZRwkzCFw
X-Received: by 2002:a17:907:447e:: with SMTP id oo22mr73667835ejb.169.1564560191855;
        Wed, 31 Jul 2019 01:03:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564560191; cv=none;
        d=google.com; s=arc-20160816;
        b=WU87aRjWYwS3UciCmN7Ek3ugbrKqtRNbnoA/7WpCr4zpFDWlDqbyHHaJ5V8T8iWq+4
         EHeiMfqMQjvGdiWtFfVOaCtPGM8gMQe6eFBvNwkCjPIT4vzVQlMJrIeQVTBnXIMoQpIp
         xpsMbEA+oKLuCW4ubwhOsZNi509/h1ax03ZhJCu9jRMwJo9uMOeJrbyQk8suV3ucwOha
         SitDIKmxADXtNiFB0qfpPm9F+2G2gsdoj0aimDwd/MAvs63pmtO+kXVT4sQKlFkWBRMy
         PKtHhC0kV5GLnzC60BEAffp7t+AVBx54YCjuCkgZIR2Wa0UjufXVcX+pXQpGd4pjH/BW
         kvqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P5gAHFdYTTIUirtAf6BErUeidAjSkmDOewDij3+SGes=;
        b=gGl+k597Wj4a5ZScmxLrYkCYoHYjF9Sjf6IsX1pER5rl91fxYa54+f9K6TqvPDcg9t
         zcsNeddT1b7NFGyLgcdw/ib5vfrjtiZOXUbM+q1WCMRUYv0sqXUodfHyFb8lqfxBiZyT
         tyDGi9qqJpzqvEK5IXPWZP5tVghmc9JrRNY11OHK22VMyDHe3PYIy+a/2H+TD/rIQlAI
         uoBEpMgbfu33nf+wVQWaMANpcvZE2PnfgdmC1kvPWuIPvtns7MqmJzVHqqANKPJ1wWqI
         ydvFuGV2/A0NzpU/XyId5PgsPDjf6Embqu95t7B0GWfYGAJ5PMw/DkGt6kn6LLUT2uTR
         /UvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s29si20036069ejm.105.2019.07.31.01.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:03:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8CE3BAEAE;
	Wed, 31 Jul 2019 08:03:10 +0000 (UTC)
Date: Wed, 31 Jul 2019 10:03:09 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Hoan Tran OS <hoan@os.amperecomputing.com>,
	Will Deacon <will@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	Paul Mackerras <paulus@samba.org>,
	"H . Peter Anvin" <hpa@zytor.com>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	"x86@kernel.org" <x86@kernel.org>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Open Source Submission <patches@amperecomputing.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Will Deacon <will.deacon@arm.com>, Borislav Petkov <bp@alien8.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	Oscar Salvador <osalvador@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"David S . Miller" <davem@davemloft.net>,
	"willy@infradead.org" <willy@infradead.org>
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Message-ID: <20190731080309.GZ9330@dhcp22.suse.cz>
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
 <20190712070247.GM29483@dhcp22.suse.cz>
 <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
 <20190712121223.GR29483@dhcp22.suse.cz>
 <20190712143730.au3662g4ua2tjudu@willie-the-truck>
 <20190712150007.GU29483@dhcp22.suse.cz>
 <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
 <20190730081415.GN9330@dhcp22.suse.cz>
 <20190731062420.GC21422@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731062420.GC21422@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 09:24:21, Mike Rapoport wrote:
> [ sorry for a late reply too, somehow I missed this thread before ]
> 
> On Tue, Jul 30, 2019 at 10:14:15AM +0200, Michal Hocko wrote:
> > [Sorry for a late reply]
> > 
> > On Mon 15-07-19 17:55:07, Hoan Tran OS wrote:
> > > Hi,
> > > 
> > > On 7/12/19 10:00 PM, Michal Hocko wrote:
> > [...]
> > > > Hmm, I thought this was selectable. But I am obviously wrong here.
> > > > Looking more closely, it seems that this is indeed only about
> > > > __early_pfn_to_nid and as such not something that should add a config
> > > > symbol. This should have been called out in the changelog though.
> > > 
> > > Yes, do you have any other comments about my patch?
> > 
> > Not really. Just make sure to explicitly state that
> > CONFIG_NODES_SPAN_OTHER_NODES is only about __early_pfn_to_nid and that
> > doesn't really deserve it's own config and can be pulled under NUMA.
> > 
> > > > Also while at it, does HAVE_MEMBLOCK_NODE_MAP fall into a similar
> > > > bucket? Do we have any NUMA architecture that doesn't enable it?
> > > > 
> 
> HAVE_MEMBLOCK_NODE_MAP makes huge difference in node/zone initialization
> sequence so it's not only about a singe function.

The question is whether we want to have this a config option or enable
it unconditionally for each NUMA system.

> > > As I checked with arch Kconfig files, there are 2 architectures, riscv 
> > > and microblaze, do not support NUMA but enable this config.
> 
> My take would be that riscv will support NUMA some day.
>  
> > > And 1 architecture, alpha, supports NUMA but does not enable this config.
> 
> alpha's NUMA support is BROKEN for more than a decade now, I doubt it'll
> ever get fixed.

I can see Al has marked it BROKEN in 2005. Maybe time to rip it out?
Although it doesn't seem to be a lot of code in arch/alpha at first
glance so maybe not worth an effort.
-- 
Michal Hocko
SUSE Labs

