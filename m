Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2A66B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 23:53:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r79so954233wrb.7
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 20:53:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor1948873wrv.84.2017.10.25.20.53.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Oct 2017 20:53:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz> <150549651001.4512.15084374619358055097@takondra-t460s>
 <20170918163434.GA11236@cmpxchg.org> <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Thu, 26 Oct 2017 09:23:26 +0530
Message-ID: <CAOaiJ-=jA-PKYFngt+4W-fJOUo-NxkvJguRDXjiDnKJ+9_00pw@mail.gmail.com>
Subject: Re: Detecting page cache trashing state
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco)" <rruslich@cisco.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Taras Kondratiuk <takondra@cisco.com>, Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, xe-linux-external@cisco.com, linux-kernel@vger.kernel.org

On Thu, Sep 28, 2017 at 9:19 PM, Ruslan Ruslichenko -X (rruslich -
GLOBALLOGIC INC at Cisco) <rruslich@cisco.com> wrote:
> Hi Johannes,
>
> Hopefully I was able to rebase the patch on top v4.9.26 (latest supported
> version by us right now)
> and test a bit.
> The overall idea definitely looks promising, although I have one question on
> usage.
> Will it be able to account the time which processes spend on handling major
> page faults
> (including fs and iowait time) of refaulting page?
>
> As we have one big application which code space occupies big amount of place
> in page cache,
> when the system under heavy memory usage will reclaim some of it, the
> application will
> start constantly thrashing. Since it code is placed on squashfs it spends
> whole CPU time
> decompressing the pages and seem memdelay counters are not detecting this
> situation.
> Here are some counters to indicate this:
>
> 19:02:44        CPU     %user     %nice   %system   %iowait %steal     %idle
> 19:02:45        all      0.00      0.00    100.00      0.00 0.00      0.00
>
> 19:02:44     pgpgin/s pgpgout/s   fault/s  majflt/s  pgfree/s pgscank/s
> pgscand/s pgsteal/s    %vmeff
> 19:02:45     15284.00      0.00    428.00    352.00  19990.00 0.00      0.00
> 15802.00      0.00
>
> And as nobody actively allocating memory anymore looks like memdelay
> counters are not
> actively incremented:
>
> [:~]$ cat /proc/memdelay
> 268035776
> 6.13 5.43 3.58
> 1.90 1.89 1.26
>
> Just in case, I have attached the v4.9.26 rebased patched.
>
Looks like this 4.9 version does not contain the accounting in lock_page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
