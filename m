Date: Thu, 31 May 2007 06:43:27 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 12/41] fs: introduce write_begin, write_end, and perform_write aops
Message-ID: <20070531044327.GD20107@wotan.suse.de>
References: <20070524052844.860329000@suse.de> <20070524053155.065366000@linux.local0.net> <20070530213035.d7b6e3e0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070530213035.d7b6e3e0.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 30, 2007 at 09:30:35PM -0700, Andrew Morton wrote:
> On Fri, 25 May 2007 22:21:56 +1000 npiggin@suse.de wrote:
> 
> > These are intended to replace prepare_write and commit_write with more
> > flexible alternatives that are also able to avoid the buffered write
> > deadlock problems efficiently (which prepare_write is unable to do).
> 
> It doesn't like LTP's vmsplice01:
> 
> ------------[ cut here ]------------
> kernel BUG at fs/buffer.c:1829!
> invalid opcode: 0000 [#1]
> SMP 
> Modules linked in:
> CPU:    0
> EIP:    0060:[<c01a2938>]    Not tainted VLI
> EFLAGS: 00010206   (2.6.22-rc3-mm1 #1)
> EIP is at __block_prepare_write+0x348/0x360
> eax: 4000081d   ebx: c176f10c   ecx: 000001f0   edx: c176f10c
> esi: df877670   edi: deeae3f0   ebp: de89fdc0   esp: de89fd60
> ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
> Process vmsplice01 (pid: 15759, ti=de89e000 task=c3ac1100 task.ti=de89e000)
> Stack: c0140083 de89fd7c 00000046 00000000 c2fffe20 000001f0 c176f10c deeae3f0 
>        c017c982 c01ee9b7 df877668 c01ee9b7 df877670 c345f300 df877684 de89fdcc 
>        c01ee9eb c176f10c de89fdc4 c015c7ee deeae504 c176f10c df877670 deeae3f0 
> Call Trace:
>  [<c0103e1a>] show_trace_log_lvl+0x1a/0x30
>  [<c0103ed8>] show_stack_log_lvl+0xa8/0xe0
>  [<c01040f9>] show_registers+0x1e9/0x2f0
>  [<c010430f>] die+0x10f/0x240
>  [<c01044d1>] do_trap+0x91/0xc0
>  [<c0104889>] do_invalid_op+0x89/0xa0
>  [<c03f44ca>] error_code+0x72/0x78
>  [<c01a29d9>] block_write_begin+0x49/0xd0
>  [<c01c9a27>] ext3_write_begin+0xb7/0x190
>  [<c015e77f>] pagecache_write_begin+0x4f/0x150
>  [<c019f02b>] pipe_to_file+0x8b/0x140
>  [<c019ea00>] __splice_from_pipe+0x70/0x250
>  [<c019ec28>] splice_from_pipe+0x48/0x70
>  [<c019eef4>] generic_file_splice_write+0x54/0x100
>  [<c019e91f>] do_splice_from+0x5f/0x80
>  [<c019fd84>] sys_splice+0x164/0x200
>  [<c0102d8e>] sysenter_past_esp+0x5f/0x99
>  =======================
> INFO: lockdep is turned off.
> Code: 49 c0 89 44 24 0c 89 7c 24 08 89 5c 24 04 c7 04 24 ac 2a 49 c0 e8 e9 ff f7 ff e8 b4 21 f6 ff 8b 4d f0 e9 a6 fe ff ff 0f 0b eb fe <0f> 0b eb fe 8d 74 26 00 0f 0b eb fe 0f 0b eb fe 90 8d b4 26 00 
> EIP: [<c01a2938>] __block_prepare_write+0x348/0x360 SS:ESP 0068:de89fd60
> 
> 
> That's
> 
> 	BUG_ON(to > PAGE_CACHE_SIZE);


Thanks. Hmm, sorry I didn't test splice much. Does this fix it?

---
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -570,7 +570,7 @@ static int pipe_to_file(struct pipe_inod
 	if (this_len + offset > PAGE_CACHE_SIZE)
 		this_len = PAGE_CACHE_SIZE - offset;
 
-	ret = pagecache_write_begin(file, mapping, sd->pos, sd->len,
+	ret = pagecache_write_begin(file, mapping, sd->pos, this_len,
 				AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
 	if (unlikely(ret))
 		goto out;
@@ -587,7 +587,7 @@ static int pipe_to_file(struct pipe_inod
 		buf->ops->unmap(pipe, buf, src);
 	}
 
-	ret = pagecache_write_end(file, mapping, sd->pos, sd->len, sd->len, page, fsdata);
+	ret = pagecache_write_end(file, mapping, sd->pos, this_len, this_len, page, fsdata);
 
 out:
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
