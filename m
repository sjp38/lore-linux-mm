Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC3E76B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 16:04:10 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id m98so179561305iod.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 13:04:10 -0800 (PST)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id u188si13415372itc.29.2017.01.17.13.04.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 13:04:10 -0800 (PST)
Received: by mail-io0-x241.google.com with SMTP id m98so17109336iod.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 13:04:10 -0800 (PST)
Content-Type: multipart/signed; boundary="Apple-Mail=_3F1B0F1C-EDE1-486B-8DD2-6D2F9C267C7A"; protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 8/8] Revert "ext4: fix wrong gfp type under transaction"
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20170117155916.dcizr65bwa6behe7@thunk.org>
Date: Tue, 17 Jan 2017 14:04:03 -0700
Message-Id: <7EC66AC2-1900-4328-A408-65079616A518@dilger.ca>
References: <20170106141107.23953-1-mhocko@kernel.org> <20170106141107.23953-9-mhocko@kernel.org> <20170117025607.frrcdbduthhutrzj@thunk.org> <20170117082425.GD19699@dhcp22.suse.cz> <20170117151817.GR19699@dhcp22.suse.cz> <20170117155916.dcizr65bwa6behe7@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>


--Apple-Mail=_3F1B0F1C-EDE1-486B-8DD2-6D2F9C267C7A
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

On Jan 17, 2017, at 8:59 AM, Theodore Ts'o <tytso@mit.edu> wrote:
> 
> On Tue, Jan 17, 2017 at 04:18:17PM +0100, Michal Hocko wrote:
>> 
>> OK, so I've been staring into the code and AFAIU current->journal_info
>> can contain my stored information. I could either hijack part of the
>> word as the ref counting is only consuming low 12b. But that looks too
>> ugly to live. Or I can allocate some placeholder.
> 
> Yeah, I was looking at something similar.  Can you guarantee that the
> context will only take one or two bits?  (Looks like it only needs one
> bit ATM, even though at the moment you're storing the whole GFP mask,
> correct?)
> 
>> But before going to play with that I am really wondering whether we need
>> all this with no journal at all. AFAIU what Jack told me it is the
>> journal lock(s) which is the biggest problem from the reclaim recursion
>> point of view. What would cause a deadlock in no journal mode?
> 
> We still have the original problem for why we need GFP_NOFS even in
> ext2.  If we are in a writeback path, and we need to allocate memory,
> we don't want to recurse back into the file system's writeback path.
> Certainly not for the same inode, and while we could make it work if
> the mm was writing back another inode, or another superblock, there
> are also stack depth considerations that would make this be a bad
> idea.  So we do need to be able to assert GFP_NOFS even in no journal
> mode, and for any file system including ext2, for that matter.
> 
> Because of the fact that we're going to have to play games with
> current->journal_info, maybe this is something that I should take
> responsibility for, and to go through the the ext4 tree after the main
> patch series go through?  Maybe you could use xfs and ext2 as sample
> (simple) implementations?
> 
> My only ask is that the memalloc nofs context be a well defined N
> bits, where N < 16, and I'll find some place to put them (probably
> journal_info).

I think Dave was suggesting that the NOFS context allow a pointer to
an arbitrary struct, so that it is possible to dereference this in
the filesystem itself to determine if the recursion is safe or not.
That way, ext2 could store an inode pointer (if that is what it cares
about) and verify that writeback is not recursing on the same inode,
and XFS can store something different.  It would also need to store
some additional info (e.g. fstype or superblock pointer) so that it
can determine how to interpret the NOFS context pointer.

I think it makes sense to add a couple of void * pointers to the task
struct along with journal_info and leave it up to the filesystem to
determine how to use them.

Cheers, Andreas






--Apple-Mail=_3F1B0F1C-EDE1-486B-8DD2-6D2F9C267C7A
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBWH6GxHKl2rkXzB/gAQjNAg//X7dQe441ccMxqgZo937oDQfWTdQE7K0C
0LY7hCYYgZWF8uK33zFzNl4WUSPYZKpyLKqAR8nSE05Pf7MH/2GZHZeuQSr9rgqP
VSKYOGGdvrNVDnHSjyNfDYd7q+/GWGtrTG/h7UlQNMYa5xJ9UE+Hyrj0pMMIrF3I
4SzFnFlJ8X9+Zlrnyir6CjZ5R0GQySwpMZRu2ocs0ngkaWuMedQNCjkIjnBM5FdQ
4o18h7m8upGt8bGrN6YaQtxnyAb6UpnW0IS/YFf/Doyeof0LLojqOzvgdawF2L5w
5vcKJMbRsiQuel0OM9yHJstlmxqkR+R4xK8CyLAwgplmSij9dZozbsYhCooD8m47
BTraN+QVgV7jN8k37S2l24zy2Ra4H94ashJ2SuSc+hWd4LCDMMbRpF9C3c36QnPh
jpX7eCjatMlbx7YwxDjW+HDWzUJa8bEjUXHfHSMzuHtSB4KiMI/i1VoBQeMbyy5a
bAG+07c4zaOWEyeP1R26i+/Yz5XOAQk8DHHeeTUq/p4Syc+V7VY3wzKQvvvmr3Bz
EdsPYvl2DnADHMQPuQCslPa35hwnW/qAO0QLOYgNnjlFpu+Ed9sWLaxU9ICfjvlE
6LrqSixflqRfAmMQlTZuLlzj63EPC4qhvvBB9uLFRis7Yio4sIb6aMx1b/1mp5S+
d/BgBQjHlFM=
=1v+V
-----END PGP SIGNATURE-----

--Apple-Mail=_3F1B0F1C-EDE1-486B-8DD2-6D2F9C267C7A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
