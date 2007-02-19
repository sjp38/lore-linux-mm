Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id l1J9J1cM013488
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 09:19:01 GMT
Received: from nf-out-0910.google.com (nfbx29.prod.google.com [10.48.100.29])
	by spaceape9.eur.corp.google.com with ESMTP id l1J9IuWi017533
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 09:18:56 GMT
Received: by nf-out-0910.google.com with SMTP id x29so2148585nfb
        for <linux-mm@kvack.org>; Mon, 19 Feb 2007 01:18:56 -0800 (PST)
Message-ID: <6599ad830702190118r20b477d3q254c167c2fc2732@mail.gmail.com>
Date: Mon, 19 Feb 2007 01:18:55 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH][1/4] RSS controller setup
In-Reply-To: <20070219005727.da2acdab.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop>
	 <20070219065026.3626.36882.sendpatchset@balbir-laptop>
	 <20070219005727.da2acdab.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>
Cc: linux-kernel@vger.kernel.org, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

On 2/19/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> This output is hard to parse and to extend.  I'd suggest either two
> separate files, or multi-line output:
>
> usage: %lu kB
> limit: %lu kB

Two separate files would be the container usage model that I
envisaged, inherited from the way cpusets does things.

And in this case, it should definitely be the limit in one file,
readable and writeable, and the usage in another, probably only
readable.

Having to read a file called memctlr_usage to find the current limit
sounds wrong.

Hmm, I don't appear to have documented this yet, but I think a good
naming scheme for container files is <subsystem>.<whatever> - i.e.
these should be memctlr.usage and memctlr.limit. The existing
grandfathered Cpusets names violate this, but I'm not sure there's a
lot we can do about that.

> > +static int memctlr_populate(struct container_subsys *ss,
> > +                             struct container *cont)
> > +{
> > +     int rc;
> > +     if ((rc = container_add_file(cont, &memctlr_usage)) < 0)
> > +             return rc;
> > +     if ((rc = container_add_file(cont, &memctlr_limit)) < 0)
>
> Clean up the first file here?

Containers don't currently provide an API for a subsystem to clean up
files from a directory - that's done automatically when the directory
is deleted.

I think I'll probably change the API for container_add_file to return
void, but mark an error in the container itself if something goes
wrong - that way rather than all the subsystems having to check for
error, container_populate_dir() can do so at the end of calling all
the subsystems' populate methods.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
