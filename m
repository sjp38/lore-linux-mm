Date: Wed, 12 Apr 2006 13:55:12 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm1 2/6] Migrate-on-fault - check for
 misplaced page
Message-Id: <20060412135512.913754f4.pj@sgi.com>
In-Reply-To: <1144867785.5229.9.camel@localhost.localdomain>
References: <1144441108.5198.36.camel@localhost.localdomain>
	<1144441382.5198.40.camel@localhost.localdomain>
	<Pine.LNX.4.64.0604111109370.878@schroedinger.engr.sgi.com>
	<20060412094346.0a974f1c.pj@sgi.com>
	<1144867785.5229.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

> Thanks, Paul.  But, I wonder, do I even need to do this check at all?

Quite possibly you don't need that check.  I'm pretending to be on
vacation this week and avoiding thinking too hard ;).

Hmmm ... looking around for a bit ... Notice the other code that picks
off the mempolicy.zonelist when it needs to place a page under
MPOL_BIND:


/* Return a zonelist representing a mempolicy */
static struct zonelist *zonelist_policy(gfp_t gfp, struct mempolicy *policy)
{
        int nd;

        switch (policy->policy) {
        case MPOL_PREFERRED:
                ...
                break;
        case MPOL_BIND:
                /* Lower zones don't get a policy applied */
                /* Careful: current->mems_allowed might have moved */
                if (gfp_zone(gfp) >= policy_zone)
                        if (cpuset_zonelist_valid_mems_allowed(policy->v.zonelist))
                                return policy->v.zonelist;


My recollection is that it goes like this.  If someone sets a mempolicy
MPOL_BIND on some nodes, and then someone moves that task to a cpuset
that doesn't include any of the BIND nodes, then that MPOL_BIND
mempolicy is basically ignored, until such time as if/when the task
fixes it to refer to some nodes currently allowed by its cpuset.

So my 'cpuset_zone_allowed()' suggestion was wrong.

Looks like you need a 'cpuset_zonelist_valid_mems_allowed()' check, and
if that fails, behave as if they had a default mempolicy, ignoring the
MPOL_BIND setting.

Note that I still haven't given any thought to the larger issues that
others have considered for this patch ... back to vacation.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
