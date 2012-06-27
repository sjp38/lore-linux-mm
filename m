Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 323966B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 13:33:41 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2063515dak.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 10:33:40 -0700 (PDT)
Date: Wed, 27 Jun 2012 10:33:36 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: first step towards hierarchical controller
Message-ID: <20120627173336.GJ15811@google.com>
References: <1340725634-9017-1-git-send-email-glommer@parallels.com>
 <1340725634-9017-3-git-send-email-glommer@parallels.com>
 <20120626180451.GP3869@google.com>
 <20120626220809.GA4653@tiehlicka.suse.cz>
 <20120626221452.GA15811@google.com>
 <20120627125119.GE5683@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120627125119.GE5683@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>

Hello, Michal.

On Wed, Jun 27, 2012 at 02:51:19PM +0200, Michal Hocko wrote:
> > Yeah, this is something I'm seriously considering doing from cgroup
> > core.  ie. generating a warning message if the user nests cgroups w/
> > controllers which don't support full hierarchy.
> 
> This is a good idea.

And I want each controller either to do proper hierarchy or not at all
and disallow switching the behavior while mounted - at least disallow
switching off hierarchy support dynamically.

> > Just disallow clearing .use_hierarchy if it was mounted with the
> > option? 
> 
> Dunno, mount option just doesn't feel right. We do not offer other
> attributes to be set by them so it would be just confusing. Besides that
> it would require an integration into existing tools like cgconfig which
> is yet another pain just because of something that we never promissed to
> keep a certain way. There are many people who don't work with mount&fs
> cgroups directly but rather use libcgroup for that...

If the default behavior has to be switched without extra input from
userland, that should be noisy like hell and slow.  e.g. generate
warning messages whenever userland does something which is to be
deprecated - nesting when .use_hierarchy == 0, mixing .use_hierarchy
== 0 / 1, and maybe later on, using .use_hierarchy == 0 at all.

Hmm.... we need to switch other controllers over to hierarchical
behavior too.  We may as well just do it from cgroup core.  Once we
rule out all users of pseudo hierarchy - nesting with controllers
which don't support hierarchy - switching on hierarchy support
per-controller shouldn't cause much problem.

How about the following then?

* I'll add a way for controllers to tell cgroup core that full
  hierarchy support is supported and a cgroup mount option to enable
  hierarchy (cgroup core itself already uses a number of mount options
  and libgroup or whatever should be able to deal with it).

  cgroup will refuse to mount if the hierarchy option is specified
  with a controller which doesn't support hierarchy and it will also
  whine like crazy if the userland tries to nest without the mount
  option specified.

  Each controller must enforce hierarchy once so directed by cgroup
  mount option.

* While doing that, all applicable controllers will be updated to
  support hierarchy.

* After sufficient time has passed, nesting without the mount option
  specified will be failed by cgroup core.

As for memcg's .use_hierarchy, make it RO 1 if the cgroup indicates
that hierarchy should be used.  Otherwise, I don't know but make sure
it gets phased out out use somehow.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
