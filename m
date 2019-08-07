Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE2E8C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:13:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC38521922
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 11:13:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC38521922
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40BDE6B0003; Wed,  7 Aug 2019 07:13:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BC946B0006; Wed,  7 Aug 2019 07:13:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AACC6B0007; Wed,  7 Aug 2019 07:13:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 054A26B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 07:13:55 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k31so82043478qte.13
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 04:13:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gC1KQ+z8aDJzLBHn0NscGQje08VcKxlWh8T1iKq/3T0=;
        b=czxFKlUNMwSF0gcF/6wPRSCxBZyF+rHJxzXQdyAj1yGrvgWiofXp7oDDXg088Rn03a
         8QPJlgMhBtmsu5w8n6K18rv09HsIWJrdW7Ax6e7v/kpWqPgOZCspC19lGBRJeRpiYg+b
         fNCrOL54HQOArYY4msL26fwSEEW03GUIjUGq06UhS7U3JVw4IfkrV+iMSV9+zYolcz5t
         UuT2LdWlgGM+oUUWlqEWa0KzcrH6QJ4tbRI9CsQxF9g5w8Ok/IVojjlUdKMGowmNk/vG
         49lIeX285So75S0AFReAYrukkd0H9/aZsdX05E1a//oz9AquFhZwJKXaVUNsVhsaIOR2
         PLVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVBSNpesGt4o+2m8rkVCytv71ll78W4skAz/YFilw2J570UnwtZ
	l+RNj/wqKAAZO6e93v75D2UI+nIW4Js225ntyFdmqE0CMfqOAmw5Fz2/UoUXx1qNj7yJqBAOg7Q
	3f+wCEfietFOhjrLBzosw2rQlg0DPCwEmWMjOQTYe0Llcw1f59sG5KGNYTESYMA6CWw==
X-Received: by 2002:aed:3742:: with SMTP id i60mr7487592qtb.376.1565176434783;
        Wed, 07 Aug 2019 04:13:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5pNATGAa+300wPCP6toE0BW5hMJn7sR1FLIw/U7toY1C/U/lb9TBYasx+zjP3vMhwKi/z
X-Received: by 2002:aed:3742:: with SMTP id i60mr7487522qtb.376.1565176433905;
        Wed, 07 Aug 2019 04:13:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565176433; cv=none;
        d=google.com; s=arc-20160816;
        b=moTF01gss7Z9fZ0GeFZcGP68ZO11vrP+B6poaAzE36yh/+17PXR8q3iTez9ISfUiUX
         MbHoUQ9PWVHz2Q9jL+ar2zkvh4wbxgH8TQ0vbgUUjnAkrLlFpDg6zSBmvFEgHFUL7SSO
         U1GuPM7d2ZVQqrlSWdC2DFc3soZPeqdrW58vJHc79SSL78JT78BZp2p+3CrpZITkN7In
         Mvt+eCU25oeFlEP9c0kIYDhOsng8EpXwMggBqWlrWI4oXO+MhTNt42HvCcsT0F8Tcfug
         Y8RUIBQcjrAlvp7NZNPI/24Kvr6tSLWquEyrTmV+fyqf+GR6JiMNaDp6eOj0ktyq2gSB
         FiCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gC1KQ+z8aDJzLBHn0NscGQje08VcKxlWh8T1iKq/3T0=;
        b=UFBvNBrvctdWDA+Opb+RKHcv/UorCttXcEYJnK1nA5RtYCfvrBJ/sT0lVjaDWT1Cxg
         A+6LRBmdGcJnVJJEY8UX8+XB2IUKLpAB2KjNrubDmFbgl2za84AXSzZAuCwLaF7a86dW
         YUWPLLsJ2j0rTzhqJC9p7hUapBfK3yFSU1yPkPRj5hB8SVa++jUTociHNI+C2/KLGyDc
         ybNEuaVUKfYpItxCzOZH8fklL5O2/3sP/TMh8PdCBJiF1JZQe/ctQOIvNg5KslAtbykA
         fUdaNRQZqMRWgXMLBS2MTINJz+FMNErUyX8UJed2Xj8NytKlMK8T36c20iSsyVowNOSM
         geMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y198si49897535qka.85.2019.08.07.04.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 04:13:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 170ED69066;
	Wed,  7 Aug 2019 11:13:53 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8C3031E4;
	Wed,  7 Aug 2019 11:13:52 +0000 (UTC)
Date: Wed, 7 Aug 2019 07:13:50 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 01/24] mm: directed shrinker work deferral
Message-ID: <20190807111350.GA19707@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-2-david@fromorbit.com>
 <20190802152709.GA60893@bfoster>
 <20190804014930.GR7777@dread.disaster.area>
 <20190805174226.GB14760@bfoster>
 <20190805234318.GB7777@dread.disaster.area>
 <20190806122754.GA2979@bfoster>
 <20190806222220.GL7777@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806222220.GL7777@dread.disaster.area>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 07 Aug 2019 11:13:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 08:22:20AM +1000, Dave Chinner wrote:
> On Tue, Aug 06, 2019 at 08:27:54AM -0400, Brian Foster wrote:
> > If you add a generic "defer work" knob to the shrinker mechanism, but
> > only process it as an "allocation context" check, I expect it could be
> > easily misused. For example, some shrinkers may decide to set the the
> > flag dynamically based on in-core state.
> 
> Which is already the case. e.g. There are shrinkers that don't do
> anything because a try-lock fails.  I haven't attempted to change
> them, but they are a clear example of how even ->scan_object to
> ->scan_object the shrinker context can change. 
> 

That's a similar point to what I'm trying to make wrt to
->count_objects() and the new defer state..

> > This will work when called from
> > some contexts but not from others (unrelated to allocation context),
> > which is confusing. Therefore, what I'm saying is that if the only
> > current use case is to defer work from shrinkers that currently skip
> > work due to allocation context restraints, this might be better codified
> > with something like the appended (untested) example patch. This may or
> > may not be a preferable interface to the flag, but it's certainly not an
> > overcomplication...
> 
> I don't think this is the right way to go.
> 
> I want the filesystem shrinkers to become entirely non-blocking so
> that we can dynamically decide on an object-by-object basis whether
> we can reclaim the object in GFP_NOFS context.
> 

This is why I was asking about whether/how you envisioned the defer flag
looking in the future. Though I think this is somewhat orthogonal to the
discussion between having a bool or internal alloc mask set, because
both are of the same granularity and would need to change to operate on
a per objects basis.

> That is, a clean XFS inode that requires no special cleanup can be
> reclaimed even in GFP_NOFS context. The problem we have is that
> dentry reclaim can drop the last reference to an inode, causing
> inactivation and hence modification. However, if it's only going to
> move to the inode LRU and not evict the inode, we can reclaim that
> dentry. Similarly for inodes - if evicting the inode is not going to
> block or modify the inode, we can reclaim the inode even under
> GFP_NOFS constraints. And the same for XFS indoes - it if's clean
> we can reclaim it, GFP_NOFS context or not.
> 
> IMO, that's the direction we need to be heading in, and in those
> cases the "deferred work" tends towards a count of objects we could
> not reclaim during the scan because they require blocking work to be
> done. i.e. deferred work is a boolean now because the GFP_NOFS
> decision is boolean, but it's lays the ground work for deferred work
> to be integrated at a much finer-grained level in the shrinker
> scanning routines in future...
> 

Yeah, this sounds more like it warrants a ->nr_deferred field or some
such, which could ultimately replace either of the previously discussed
options for deferring the entire instance. BTW, ISTM we could use that
kind of interface now for exactly what this patch is trying to
accomplish by changing those shrinkers with allocation context
restrictions to just transfer the entire scan count to the deferred
count in ->scan_objects() instead of setting the flag. That's somewhat
less churn in the long run because we aren't shifting the defer logic
back and forth between the count and scan callbacks unnecessarily. IMO,
it's also a cleaner interface than both options above.

Brian

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com

