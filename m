Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C58F6B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 06:29:48 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so4248416eda.3
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:29:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k1si2617859eda.363.2018.11.14.03.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 03:29:46 -0800 (PST)
Date: Wed, 14 Nov 2018 12:29:45 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] Fix do_move_pages_to_node() error handling
Message-ID: <20181114112945.GQ23419@dhcp22.suse.cz>
References: <20181114004059.1287439-1-pjaroszynski@nvidia.com>
 <20181114073415.GD23419@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181114073415.GD23419@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: p.jaroszynski@gmail.com
Cc: linux-mm@kvack.org, Piotr Jaroszynski <pjaroszynski@nvidia.com>, Jan Stancek <jstancek@redhat.com>

On Wed 14-11-18 08:34:15, Michal Hocko wrote:
> On Tue 13-11-18 16:40:59, p.jaroszynski@gmail.com wrote:
> > From: Piotr Jaroszynski <pjaroszynski@nvidia.com>
> > 
> > migrate_pages() can return the number of pages that failed to migrate
> > instead of 0 or an error code. If that happens, the positive return is
> > treated as an error all the way up through the stack leading to the
> > move_pages() syscall returning a positive number. I believe this
> > regressed with commit a49bd4d71637 ("mm, numa: rework do_pages_move")
> > that refactored a lot of this code.
> 
> Yes this is correct.
> 
> > Fix this by treating positive returns as success in
> > do_move_pages_to_node() as that seems to most closely follow the
> > previous code. This still leaves the question whether silently
> > considering this case a success is the right thing to do as even the
> > status of the pages will be set as if they were successfully migrated,
> > but that seems to have been the case before as well.
> 
> Yes, I believe the previous semantic was just wrong and we want to fix
> it. Jan has already brought this up [1]. I believe we want to update the
> documentation rather than restore the previous hazy semantic.
> 
> Just wondering, how have you found out? Is there any real application
> failing because of the change or this is a result of some test?
> 
> [1] http://lkml.kernel.org/r/0329efa0984b9b0252ef166abb4498c0795fab36.1535113317.git.jstancek@redhat.com

Btw. this is what I was suggesting back then (along with the man page
update suggested by Jan)
