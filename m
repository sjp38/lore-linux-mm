Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42795C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 18:10:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0017920833
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 18:10:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0017920833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 90F116B0005; Thu, 16 May 2019 14:10:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BEA46B0006; Thu, 16 May 2019 14:10:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AD656B0007; Thu, 16 May 2019 14:10:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 29E396B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 14:10:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y22so6495498eds.14
        for <linux-mm@kvack.org>; Thu, 16 May 2019 11:10:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=P6hT8kL6tgUuPBHOAjvQtWyAeF+FdQwG/9cEBU3uYXM=;
        b=ABS6mpptISs4hJrt6cqj9sJBbO8/Mq1UY8+Qw5gbR8CWgTjfKt7mbDrccqdOvclMNA
         F0kptkrCznkB/sIrkAnMqSpebwm7xGZ/qz6IdsVCMwkH0GAwbzog6oCQa/0V8izKcU1E
         EdWR9PKFBH3IlHuCOM7Gbz0ux+Zmbscs7HHflKhKwqVQlkRbGxvnZ8sQmyZD7er6fiFS
         4KUKOAiUncc2edxxyBzlvUTpfPZOGMnn+D+RkRE++lxpsL9JjL2Ch/umREMsvdw0NC1a
         N/WNL72JvIgDxlg6V8YgddF/gi+M4EkViX5ctIVq6a8BSrpW4PHHjLXBAqXVX7DFE6WT
         SJCg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWGF9Jhq/BKI1m+6VG0MHloiX524Sp9Ufq45MtOW4mToUaRNexb
	1TgG0hiRIZoF4EkSSknDKif9K+mD1kQj8HSB2Z5F6cViTBPpGzI0ZL2u8u3QwAuY0G77eF4rzUg
	MC4qHCqUFEgqVepqiPt9TH0Kw5B3G48rHqwvaDhhEIthMQOzT/wIhKhdHmp0pWC4=
X-Received: by 2002:a17:906:f19a:: with SMTP id gs26mr33164498ejb.78.1558030245679;
        Thu, 16 May 2019 11:10:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyISbc//tzmX0A+pSVAH6eKowMb8vwyS9hM9g8K+nka3LI/H3dtNjo59Wf/yCONzeoNCYc7
X-Received: by 2002:a17:906:f19a:: with SMTP id gs26mr33164411ejb.78.1558030244720;
        Thu, 16 May 2019 11:10:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558030244; cv=none;
        d=google.com; s=arc-20160816;
        b=fZOhqLSWCGVTDuPEaIQSCVWrIaIExxI4CZSLsx06AUKb8Kridg6dZkvJtRe1LH/DUJ
         eGwA8g/s/ly0LCrybCKUEV6K/0RzPRRwkT+hf0IJPQ263bdwtcN+Zlth23jEa2jbZ03q
         RATAZpyyDc5a8BoOinzmzY3lOwqFrHnqD8R69KYN1UkZjw6j6yXRZY6j0UpPooAldn85
         sws7Lx2AdT9W1AoCLVPi/6v2JTxG5Cp78AaX3uwVl598oP8KMYgzyEdBSwpnk52og3KK
         BJOAVIyBtyM6ItgyblPF1HPm8oNxXgeTdho0+7aFrMilSBKUmKev1t+9Ob4WwqyzD9Td
         WYOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=P6hT8kL6tgUuPBHOAjvQtWyAeF+FdQwG/9cEBU3uYXM=;
        b=Q2CpfTfucObHKPfTiVOshx2dGtGZ+USKNzZTa5RkyH3IGVih5YzVD2J6gfBjY6rYB5
         TyTRVznL/YGeQBixd72LE/ReBuRQ3wyoFBkkDU4DZnrQ7XkNBnzMTYISqhkgsGALeMyN
         rmpvVmDGzjEYb96OwYSzgGVU2aWuRr9+BzmbwHrRGGjPR6Ljfbl/OmBCs0O+763dAYlT
         m5i2qfyfrVvmSQck2jeZPveSbtYc+mXjfcZyXsiWF3N17XyyZ4q4klgWYa5gAiXX7COe
         s5yyaWlFip8SuYx7zRO5xb5bZCSIPEPD/MTvfVwpWmqWQ1z38++XqThfsW1szoG7F0eV
         KTFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr23si3747160ejb.188.2019.05.16.11.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 11:10:44 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DE7ABAF26;
	Thu, 16 May 2019 18:10:43 +0000 (UTC)
Date: Thu, 16 May 2019 20:10:42 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mm-commits@vger.kernel.org, tj@kernel.org,
	guro@fb.com, dennis@kernel.org, chris@chrisdown.name,
	cgroups mailinglist <cgroups@vger.kernel.org>, linux-mm@kvack.org
Subject: Re: + mm-consider-subtrees-in-memoryevents.patch added to -mm tree
Message-ID: <20190516180932.GA13208@dhcp22.suse.cz>
References: <20190212224542.ZW63a%akpm@linux-foundation.org>
 <20190213124729.GI4525@dhcp22.suse.cz>
 <20190516175655.GA25818@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190516175655.GA25818@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 16-05-19 13:56:55, Johannes Weiner wrote:
> On Wed, Feb 13, 2019 at 01:47:29PM +0100, Michal Hocko wrote:
> > On Tue 12-02-19 14:45:42, Andrew Morton wrote:
> > [...]
> > > From: Chris Down <chris@chrisdown.name>
> > > Subject: mm, memcg: consider subtrees in memory.events
> > > 
> > > memory.stat and other files already consider subtrees in their output, and
> > > we should too in order to not present an inconsistent interface.
> > > 
> > > The current situation is fairly confusing, because people interacting with
> > > cgroups expect hierarchical behaviour in the vein of memory.stat,
> > > cgroup.events, and other files.  For example, this causes confusion when
> > > debugging reclaim events under low, as currently these always read "0" at
> > > non-leaf memcg nodes, which frequently causes people to misdiagnose breach
> > > behaviour.  The same confusion applies to other counters in this file when
> > > debugging issues.
> > > 
> > > Aggregation is done at write time instead of at read-time since these
> > > counters aren't hot (unlike memory.stat which is per-page, so it does it
> > > at read time), and it makes sense to bundle this with the file
> > > notifications.
> > > 
> > > After this patch, events are propagated up the hierarchy:
> > > 
> > >     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
> > >     low 0
> > >     high 0
> > >     max 0
> > >     oom 0
> > >     oom_kill 0
> > >     [root@ktst ~]# systemd-run -p MemoryMax=1 true
> > >     Running as unit: run-r251162a189fb4562b9dabfdc9b0422f5.service
> > >     [root@ktst ~]# cat /sys/fs/cgroup/system.slice/memory.events
> > >     low 0
> > >     high 0
> > >     max 7
> > >     oom 1
> > >     oom_kill 1
> > > 
> > > As this is a change in behaviour, this can be reverted to the old
> > > behaviour by mounting with the `memory_localevents' flag set.  However, we
> > > use the new behaviour by default as there's a lack of evidence that there
> > > are any current users of memory.events that would find this change
> > > undesirable.
> > > 
> > > Link: http://lkml.kernel.org/r/20190208224419.GA24772@chrisdown.name
> > > Signed-off-by: Chris Down <chris@chrisdown.name>
> > > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Tejun Heo <tj@kernel.org>
> > > Cc: Roman Gushchin <guro@fb.com>
> > > Cc: Dennis Zhou <dennis@kernel.org>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > FTR: As I've already said here [1] I can live with this change as long
> > as there is a larger consensus among cgroup v2 users. So let's give this
> > some more time before merging to see whether there is such a consensus.
> > 
> > [1] http://lkml.kernel.org/r/20190201102515.GK11599@dhcp22.suse.cz
> 
> It's been three months without any objections.

It's been three months without any _feedback_ from anybody. It might
very well be true that people just do not read these emails or do not
care one way or another.

> Can we merge this for
> v5.2 please? We still have users complaining about this inconsistent
> behavior (the last one was yesterday) and we'd rather not carry any
> out of tree patches.

Could you point me to those complains or is this something internal?
-- 
Michal Hocko
SUSE Labs

