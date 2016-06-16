Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A99E86B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:27:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id k184so24760017wme.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:27:53 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id v198si5302910wmf.69.2016.06.16.03.27.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 03:27:52 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 187so8352627wmz.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:27:52 -0700 (PDT)
Date: Thu, 16 Jun 2016 12:27:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 03/18] memcontrol: present maximum used memory also for
 cgroup-v2
Message-ID: <20160616102750.GG6836@dhcp22.suse.cz>
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
 <1465847065-3577-4-git-send-email-toiwoton@gmail.com>
 <20160614070130.GB5681@dhcp22.suse.cz>
 <b9d04ccd-28d2-993a-2a40-bbed7b6289d4@gmail.com>
 <20160614160410.GB14279@cmpxchg.org>
 <db6a51eb-d1f7-691b-11a6-ef0b7c1c9462@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <db6a51eb-d1f7-691b-11a6-ef0b7c1c9462@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Topi Miettinen <toiwoton@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <cgroups@vger.kernel.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)" <linux-mm@kvack.org>

On Tue 14-06-16 17:15:06, Topi Miettinen wrote:
> On 06/14/16 16:04, Johannes Weiner wrote:
[...]
> > I didn't catch the coverletter, though. It makes sense to CC
> > recipients of any of those patches on the full series, including the
> > cover, since even though we are specialized in certain areas of the
> > code, many of us are interested in the whole picture of addressing a
> > problem, and not just the few bits in our area without more context.
> > 
> 
> Thank you for this nice explanation. I suppose "git send-email
> --cc-cmd=scripts/get_maintainer.pl" doesn't do this.

No it doesn't. What I do for this kind of series is the following. Put
an explicit CC (acked, reviews etc...) to each patch. git format-patch
$RANGE and then
$ git send-email --cc-cmd=./cc-cmd-only-cover.sh $DEFAULT_TO_CC --compose *.patch

$ cat cc-cmd-only-cover.sh
#!/bin/bash

if [[ $1 == *gitsendemail.msg* || $1 == *cover-letter* ]]; then
        grep '<.*@.*>' -h *.patch | sed 's/^.*: //' | sort | uniq
fi

A bit error prone because you have to cleanup any previous patch files
from the directory but works more or less well for me.

s 
> > As far as the memcg part of this series goes, one concern is that page
> > cache is trimmed back only when there is pressure, so in all but very
> > few cases the high watermark you are introducing will be pegged to the
> > configured limit. It doesn't give a whole lot of insight.
> > 
> 
> So using the high watermark would not give a very useful starting point
> for the user who wished to configure the memory limit? What else could
> be used instead?

we have an event notification mechanism. In v1 it is vmpressure and v2
you will get a notification when the high/max limit is hit or when we
hit the oom.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
