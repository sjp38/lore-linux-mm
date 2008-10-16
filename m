Date: Wed, 15 Oct 2008 22:41:41 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH updated] ext4: Fix file fragmentation during large file
	write.
Message-ID: <20081016024141.GA15487@mit.edu>
References: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1224103260.6938.45.camel@think.oraclecorp.com> <1224114692.6938.48.camel@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1224114692.6938.48.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, cmm@us.ibm.com, sandeen@redhat.com, akpm@linux-foundation.org, hch@infradead.org, steve@chygwyn.com, npiggin@suse.de, mpatocka@redhat.com, linux-mm@kvack.org, inux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 15, 2008 at 07:51:32PM -0400, Chris Mason wrote:
> 
> Just FYI, I ran this with compilebench -i 20 --makej and my log is full
> of these:
> 
> ext4_da_writepages: jbd2_start: 1024 pages, ino 520417; err -30
> Pid: 4072, comm: pdflush Not tainted 2.6.27 #2

That's from ext4_journal_start_sb:

       if (sb->s_flags & MS_RDONLY)
       	  return ERR_PTR(-EROFS);

What was the very first error in your log?  It looks like ext4 somehow
flagged some kind of filesystem error or aborted the journal due to
some failure, and log gets filled these messages.  We should probably 
should throttle these messages by simply putting a

       if (sb->s_flags & MS_RDONLY)
		return -ERNOFS;

at the beginning of ext4_da_writepages() so we don't fill the logs
with extraneous messages that obscure more important error messages.

     			      	      	   	     - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
