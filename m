Message-ID: <4292B361.80500@engr.sgi.com>
Date: Mon, 23 May 2005 23:53:53 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2
 -- xfs-extended-attributes-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com> <20050511125932.GW25612@wotan.suse.de> <42825236.1030503@engr.sgi.com> <20050511193207.GE11200@wotan.suse.de> <20050512104543.GA14799@infradead.org> <428E6427.7060401@engr.sgi.com> <429217F8.5020202@mwwireless.net>
In-Reply-To: <429217F8.5020202@mwwireless.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Longerbeam <stevel@mwwireless.net>
Cc: Christoph Hellwig <hch@infradead.org>, Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@wildopensource.com>
List-ID: <linux-mm.kvack.org>

Steve Longerbeam wrote:
> 
> 
>
> 
> I have a question about the migration attributes. Are these attributes
> needed because your migration code is not _capable_ of migrating
> shared pages? Or is it that you just want to selectively choose which
> shared object memory should and should not be migrated?
> 
> Steve
> 

Hi Steve,

The reason the migration attributes are required is that from inside the
kernel, whilst looking at VMA's in the migration code, all mapped files
look alike.  There is no way to tell the difference (AFAIK) between:

(1)  A regular mapped file that the user mapped in and is shared
      among the processes that are being migrated.
(2)  A mapped file that maps a shared library.
(3)  A mapped file that maps a shared executable (e. g. /bin/bash).

We need to take a different migration action based on which case we
are in:

(1)  Migrate all of the pages.
(2)  Migrate the non-shared pages.
(3)  Migrate none of the pages.

So we need some external way for the kernel to be told which kind of
mapped file this is.  That is why we need some kind of interface for
the user (or admininistrator) to tell us how to classify each shared
mapped file.

(Obviously, we could make some assumptions about file names and catch
a lot of these, but then you would need a configerable interfac to
the kernel to control those names, and that seems like a problem.)

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
