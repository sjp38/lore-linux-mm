From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] fs: clear file set[ug]id when writing via mmap
Date: Thu, 19 Nov 2015 16:10:43 -0800
Message-ID: <20151120001043.GA28204@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Shachar Raindel <raindel@mellanox.com>, Boaz Harrosh <boaz@plexistor.com>, Michal Hocko <mhocko@suse.cz>, Haggai Eran <haggaie@mellanox.com>, Theodore Tso <tytso@google.com>, Willy Tarreau <w@1wt.eu>, Dirk Steinmetz <public@rsjtdrjgfuzkfg.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>, Serge Hallyn <serge.hallyn@ubuntu.com>, Seth Forshee <seth.forshee@canonical.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@>
List-Id: linux-mm.kvack.org

Normally, when a user can modify a file that has setuid or setgid bits,
those bits are cleared when they are not the file owner or a member of the
group. This is enforced when using write() directly but not when writing
to a shared mmap on the file. This could allow the file writer to gain
privileges by changing the binary without losing the setuid/setgid bits.

Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: stable@vger.kernel.org
---
 mm/memory.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory.c b/mm/memory.c
index deb679c31f2a..4c970a4e0057 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2036,6 +2036,7 @@ static inline int wp_page_reuse(struct mm_struct *mm,
 
 		if (!page_mkwrite)
 			file_update_time(vma->vm_file);
+		file_remove_privs(vma->vm_file);
 	}
 
 	return VM_FAULT_WRITE;
-- 
1.9.1


-- 
Kees Cook
Chrome OS Security
