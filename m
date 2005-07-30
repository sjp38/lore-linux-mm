Date: Sat, 30 Jul 2005 23:13:06 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: get_user_pages() with write=1 and force=1 gets read-only pages.
In-Reply-To: <20050730205319.GA1233@lnx-holt.americas.sgi.com>
Message-ID: <Pine.LNX.4.61.0507302255390.5143@goblin.wat.veritas.com>
References: <20050730205319.GA1233@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Roland McGrath <roland@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 Jul 2005, Robin Holt wrote:

> I am chasing a bug which I think I understand, but would like some
> confirmation.
> 
> I believe I have two processes calling get_user_pages at approximately
> the same time.  One is calling with write=0.  The other with write=1
> and force=1.  The vma has the vm_ops->nopage set to filemap_nopage.
> 
> Both faulters get to the point in do_no_page of being ready to insert
> the pte.  The first one to get the mm->page_table_lock must be the reader.
> The readable pte gets inserted and results in the writer detecting the
> pte and returning VM_FAULT_MINOR.
> 
> Upon return, the writer the does 'lookup_write = write && !force;'
> and then calls follow_page without having the write flag set.
> 
> Am I on the right track with this?

I do believe you are.  Twice I've inserted fault code to cope with that
"surely no longer have a shared page we shouldn't write" assumption,
but I think you've just demonstrated that it's inherently unsafe.

Certainly goes against the traditional grain of fault handlers, which can
just try again when in doubt - as in the pte_same checks you've observed.

> Is the correct fix to not just pass in the write flag untouched?

I don't understand you there.  Suspect you're confusing me with that
"not", which perhaps expresses hesitancy, but shouldn't be there?

But the correct fix would not be to pass in the write flag untouched:
it's trying to avoid an endless loop of finding the pte not writable
when ptrace is modifying a page which the user is currently protected
against writing to (setting a breakpoint in readonly text, perhaps?).

get_user_pages is hard!  I don't know the right answer offhand,
but thank you for posing a good question.

> I believe the change was made by Roland
> McGrath, but I don't see an email address for him.

I've CC'ed roland@redhat.com

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
