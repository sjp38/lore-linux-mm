Date: Wed, 28 May 2008 11:02:57 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 22/23] fs: check for statfs overflow
Message-ID: <20080528090257.GC2630@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143454.453947000@nick.local0.net> <20080527171452.GJ20709@us.ibm.com> <483C42B9.7090102@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <483C42B9.7090102@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Tollefson <kniht@linux.vnet.ibm.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, andi@firstfloor.org, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, May 27, 2008 at 12:19:53PM -0500, Jon Tollefson wrote:
> Nishanth Aravamudan wrote:
> > On 26.05.2008 [00:23:39 +1000], npiggin@suse.de wrote:
> >   
> >> Adds a check for an overflow in the filesystem size so if someone is
> >> checking with statfs() on a 16G hugetlbfs  in a 32bit binary that it
> >> will report back EOVERFLOW instead of a size of 0.
> >>
> >> Are other places that need a similar check?  I had tried a similar
> >> check in put_compat_statfs64 too but it didn't seem to generate an
> >> EOVERFLOW in my test case.
> >>     
> >
> > I think this part of the changelog was meant to be a post-"---"
> > question, which I don't have an answer for, but probably shouldn't go in
> > the final changelog?
> >   
> You are correct.

I think the question is OK for the changelog. Unless we can get
somebody answering it yes or no, I'll leave it (but I'd rather get
an answer first).

I'm pretty unfamiliar with how the APIs work, but I'd think statfs64
is less likely to overflow because f_blocks is likely to be 8 bytes.
But I still think the check might be good to have.

The non-compat stat() (and stat64 even) might also need the eoverflow
check. cc'ing fsdevel with the patch attached again.

---

fs: check for statfs overflow

Adds a check for an overflow in the filesystem size so if someone is
checking with statfs() on a 16G hugetlbfs  in a 32bit binary that it
will report back EOVERFLOW instead of a size of 0.

Are other places that need a similar check?  I had tried a similar
check in put_compat_statfs64 too but it didn't seem to generate an
EOVERFLOW in my test case.

Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---

 fs/compat.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)


Index: linux-2.6/fs/compat.c
===================================================================
--- linux-2.6.orig/fs/compat.c
+++ linux-2.6/fs/compat.c
@@ -197,8 +197,8 @@ static int put_compat_statfs(struct comp
 {
 	
 	if (sizeof ubuf->f_blocks == 4) {
-		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail) &
-		    0xffffffff00000000ULL)
+		if ((kbuf->f_blocks | kbuf->f_bfree | kbuf->f_bavail |
+		     kbuf->f_bsize | kbuf->f_frsize) & 0xffffffff00000000ULL)
 			return -EOVERFLOW;
 		/* f_files and f_ffree may be -1; it's okay
 		 * to stuff that into 32 bits */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
