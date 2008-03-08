Subject: Re: Regression:  Re: [patch -mm 2/4] mempolicy: create
	mempolicy_operations structure
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0803071341090.26765@chino.kir.corp.google.com>
References: <alpine.DEB.1.00.0803061135001.18590@chino.kir.corp.google.com>
	 <alpine.DEB.1.00.0803061135560.18590@chino.kir.corp.google.com>
	 <1204922646.5340.73.camel@localhost>
	 <alpine.DEB.1.00.0803071341090.26765@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Sat, 08 Mar 2008 13:49:31 -0500
Message-Id: <1205002171.4918.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-03-07 at 13:48 -0800, David Rientjes wrote: 
> On Fri, 7 Mar 2008, Lee Schermerhorn wrote:
> 
> > It also appears that the patch series listed above required a non-empty
> > nodemask with MPOL_DEFAULT.  However, I didn't test that.  With this
> > patch, MPOL_DEFAULT effectively ignores the nodemask--empty or not.
> > This is a change in behavior that I have argued against, but the
> > regression tests don't test this, so I'm not going to attempt to address
> > it with this patch.
> > 
> 
> Excuse me, but there was significant discussion about this on LKML and I 
> eventually did force MPOL_DEFAULT to require a non-empty nodemask 
> specifically because of your demand that it should.  It didn't originally 
> require this in my patchset, and now you're removing the exact same 
> requirement that you demanded.
> 
> You said on February 13:
> 
> 	1) we've discussed the issue of returning EINVAL for non-empty
> 	nodemasks with MPOL_DEFAULT.  By removing this restriction, we run
> 	the risk of breaking applications if we should ever want to define
> 	a semantic to non-empty node mask for MPOL_DEFAULT.
> 
> If you want to remove this requirement now (please get agreement from 
> Paul) and are sure of your position, you'll at least need an update to 
> Documentation/vm/numa-memory-policy.txt.

Excuse me.  I thought that the discussion--my position, anyway--was
about preserving existing behavior for MPOL_DEFAULT which is to require
an EMPTY [or NULL--same effect] nodemask.  Not a NON-EMPTY one.  See:
http://www.kernel.org/doc/man-pages/online/pages/man2/set_mempolicy.2.html
It does appear that your patches now require a non-empty nodemask.  This
was intentional?

Is it, then, the case that our disagreement was based on the fact that
you thought I was advocating a non-empty nodemask with MPOL_DEFAULT?  No
wonder you said it didn't make sense. 

Since we can't seem to understand each other with ~English prose, I've
attached a little test program that demonstrates the behavior that I
expect.   This is not to belabor the point; just an attempt to establish
understanding.

Note:  in the subject patch, I didn't enforce this behavior because your
patch didn't [it enforced just the opposite], and I've pretty much given
up.  Although I prefer current behavior [before your series], if we
change it, we will need to change the man pages to remove the error
condition for non-empty nodemasks with MPOL_DEFAULT.

Later,
Lee


/*
 * test error returns for set_mempolicy(MPOL_DEFAULT, nodemask, maxnodes) for
 * null, empty and non-empty nodemasks.
 *
 * requires libnuma
 */
#include <sys/types.h>

#include <errno.h>
#include <numaif.h>
#include <numa.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void results(int ret, int ierr, int expected)
{
	if (ret) {
		printf("\tResults:   %s [%d]\n", strerror(ierr), ierr);
	} else {
		printf("\tResults:   No Error [0]\n");
	}
	printf("\tExpected:  %s [%d]\n",
			expected ? strerror(expected) : "No Error", expected);
}

int main(int argc, char *argv[])
{
	unsigned long nodemask;	/* hack:  single long word mask */
	int maxnodes = 4;	/* arbitrary max <= 8 * sizeof(nodemask) */
	int ret;

	printf("\n1: testing set_mempolicy(MPOL_DEFAULT, ...) with NULL nodemask:\n");
	ret = set_mempolicy(MPOL_DEFAULT, NULL, maxnodes);
	results(ret, errno, 0);	/* expect success */

	printf("\n2: testing set_mempolicy(MPOL_DEFAULT, ...) with non-NULL, "
			"but empty, nodemask:\n");
	nodemask = 0UL;
	ret = set_mempolicy(MPOL_DEFAULT, &nodemask, maxnodes);
	results(ret, errno, 0);	/* expect success */

	printf("\n2: testing set_mempolicy(MPOL_DEFAULT, ...) with non-NULL, "
			"non-empty nodemask:\n");
	nodemask = 1UL;
	ret = set_mempolicy(MPOL_DEFAULT, &nodemask, maxnodes);
	results(ret, errno, EINVAL);	/* expect EINVAL */

}




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
