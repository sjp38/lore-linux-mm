From: Neil Brown <neilb@suse.de>
Date: Fri, 3 Aug 2007 11:40:38 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18098.34710.118531.660512@notabene.brown>
Subject: Re: [patch][rfc] remove ZERO_PAGE?
In-Reply-To: message from J. Bruce Fields on Thursday August 2
References: <20070727021943.GD13939@wotan.suse.de>
	<e28f90730707300652g4a0d0f4ah10bd3c06564d624b@mail.gmail.com>
	<20070730115751.a2aaa28f.akpm@linux-foundation.org>
	<20070730223912.GM2386@fieldses.org>
	<20070801014739.GA30549@wotan.suse.de>
	<20070801015306.GB24887@fieldses.org>
	<e28f90730707311919y7e48c7f9we4f974d844d17739@mail.gmail.com>
	<20070802043702.GE14660@fieldses.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Luiz Fernando N. Capitulino" <lcapitulino@gmail.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, lcapitulino@mandriva.com.br
List-ID: <linux-mm.kvack.org>

On Thursday August 2, bfields@fieldses.org wrote:
> On Tue, Jul 31, 2007 at 11:19:00PM -0300, Luiz Fernando N. Capitulino wrote:
> > On 7/31/07, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > On Wed, Aug 01, 2007 at 03:47:39AM +0200, Nick Piggin wrote:
> > > > On Mon, Jul 30, 2007 at 06:39:12PM -0400, J. Bruce Fields wrote:
> > > > > It looks to me like it's oopsing at the deference of
> > > > > fhp->fh_export->ex_uuid in encode_fsid(), which is exactly the case
> > > > > commit b41eeef14d claims to fix.  Looks like that's been in since
> > > > > v2.6.22-rc1; what kernel is this?
> > > >
> > > > Any progress with this? I'm fairly sure ZERO_PAGE removal wouldn't
> > > > have triggered it.
> > >
> > > I agree that it's most likely an nfsd bug.  I'll take another look, but
> > > it probably won't be till tommorow afternoon.
> > 
> >  Bruce, is there a way to reproduce the bug b41eeef14d claims to fix?
> 
> OK, sorry, it's taking me a little time to figure out what's going on.
> 
> But fh_verify() was responsible for checking and filling in the fhp that
> is wrong here, and I don't see the safeguards in fh_verify() (or in the
> export-lookup process) that would ensure that the export associated with
> a filehandle has a non-NULL ex_uuid whenever the filehandle has a uuid
> fsid type.  But I can't create a test case yet.

I have seen this bug already.  Here is the patch I made.

But I'm not really sure how it happens.  I think you would need a
buggy mounted, and I don't think one of those has escaped.

I'll ponder a some more see what I can find.

But I'm certain this has nothing to do with ZERO_PAGE, so maybe future
followups should trim the cc list a bit.

NeilBrown

-------------------------------------
Validate filehandle type in fsid_source

fsid_source decided where to get the 'fsid' number to
return for a GETATTR based on the type of filehandle.
It can be from the device, from the fsid, or from the
UUID.

It is possible for the filehandle to be inconsistent
with the export information, so make sure the export information
actually has the info implied by the value returned by
fsid_source.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsfh.c |   20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)

diff .prev/fs/nfsd/nfsfh.c ./fs/nfsd/nfsfh.c
--- .prev/fs/nfsd/nfsfh.c	2007-07-31 11:19:20.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2007-08-03 11:31:40.000000000 +1000
@@ -566,13 +566,23 @@ enum fsid_source fsid_source(struct svc_
 	case FSID_DEV:
 	case FSID_ENCODE_DEV:
 	case FSID_MAJOR_MINOR:
-		return FSIDSOURCE_DEV;
+		if (fhp->fh_export->ex_dentry->d_inode->i_sb->s_type->fs_flags
+		    & FS_REQUIRES_DEV)
+			return FSIDSOURCE_DEV;
+		break;
 	case FSID_NUM:
-		return FSIDSOURCE_FSID;
-	default:
 		if (fhp->fh_export->ex_flags & NFSEXP_FSID)
 			return FSIDSOURCE_FSID;
-		else
-			return FSIDSOURCE_UUID;
+		break;
+	default:
+		break;
 	}
+	/* either a UUID type filehandle, or the filehandle doesn't
+	 * match the export.
+	 */
+	if (fhp->fh_export->ex_flags & NFSEXP_FSID)
+		return FSIDSOURCE_FSID;
+	if (fhp->fh_export->ex_uuid)
+		return FSIDSOURCE_UUID;
+	return FSIDSOURCE_DEV;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
