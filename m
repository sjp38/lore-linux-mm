Date: Tue, 26 Sep 2000 18:31:04 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [CFT][PATCH] ext2 directories in pagecache
In-Reply-To: <20000927001620.A26488@l-t.ee>
Message-ID: <Pine.GSO.4.21.0009261825020.22614-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marko Kreen <marko@l-t.ee>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, Alexander Viro <aviro@redhat.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Wed, 27 Sep 2000, Marko Kreen wrote:

> On Tue, Sep 26, 2000 at 05:29:27PM -0400, Alexander Viro wrote:
> > Comments and help in testing are more than welcome.
> 
> There is something fishy in ext2_empty_dir:

Why?

> +                               /* check for . and .. */
> +                               if (de->name[0] != '.')
> +                                       goto not_empty;

Doesn't start with '.' - definitely not an empty directory


> +                               if (!de->name[1]) {

OK, it's {'.','\0'}, aka. ".".

> +                                       if (de->inode !=
> +                                           le32_to_cpu(inode->i_ino))

Consistency check... Aha, I see. Yup, s/le32_to_cpu/cpu_to_le32/. Doesn't
matter on all normal architectures, but yes, it's still wrong.

> +                                               goto not_empty;

If we have it screwed - leave it as is and don't mess with it.
Otherwise - skip this record, it's all right for empty directory.

> +                               } else if (de->name[2])

Starts with '.' and longer than 2 characters? Not empty.

> +                                       goto not_empty;
> +                               else if (de->name[1] != '.')

Starts with '.', 2 characters, but the second isn't '.'? Not empty.

> +                                       goto not_empty;

Otherwise - skip the record.

	So checks are OK, the only thing being that we should use
cpu_to_le32() instead of le32_to_cpu(). Doesn't affect the behaviour right
now, but ought to be fixed anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
