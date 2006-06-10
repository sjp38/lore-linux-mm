Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: acting on all tasks mapping a dirty page
Date: Fri, 9 Jun 2006 17:31:04 -0700
Message-ID: <069061BE1B26524C85EC01E0F5CC3CC30163E20E@rigel.headquarters.spacedev.com>
From: "Brian Lindahl" <Brian.Lindahl@SpaceDev.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Given a dirty physical page, I need to perform a certain action on each process (task) that maps to it. To do this, I mark each 'mm' by tracing the list of vma's in the page's mapping. I later iterate over the task list and perform an action on each 'mm' that is marked. Because each task has it's own pte, I think I have to scan the vma list for a mapping twice.

/* locks ignored for brevity, assume atomic */

struct page * page; /* = some page */
int pte_dirty = 0;

vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
  pte_dirty; /* = via page_check_address, is the pte dirty? */

if (pte_dirty)
  vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
    mark(vma->vm_mm);

struct task_struct * task; /* = task_list */
for(; task; task = task->next_task)
  if (task->mm->marked)
    do_action(task);

Is there a better way to do this? Less importantly, is there a way to avoid two vma_prio_tree_foreach's? I didn't want to assume that the pte reference is identical for all mappings for any given page, but it looks that way. If this is true, then I can simply scan it once and use the result from the examination of pte dirty on the first vma (rather, it's owning mm)?

Thanks!

Brian Lindahl 
Embedded Software Engineer 
858-375-2077 
brian.lindahl@spacedev.com 
SpaceDev, Inc. 
"We Make Space Happen"
 
 
This email message and any information or files contained within or attached to this message may be privileged, confidential, proprietary and protected from disclosure and is intended only for the person or entity to which it is addressed.  This email is considered a business record and is therefore property of the SpaceDev, Inc.  Any direct or indirect review, re-transmission, dissemination, forwarding, printing, use, disclosure, or copying of this message or any part thereof or other use of or any file attached to this message, or taking of any action in reliance upon this information by persons or entities other than the intended recipient is prohibited.  If you received this message in error, please immediately inform the sender by reply e-mail and delete the message and any attachments and all copies of it from your system and destroy any hard copies of it.  No confidentiality or privilege is waived or lost by any mis-transmission.  SpaceDev, Inc. is neither liable for proper, complete transmission or the information contained in this communication, nor any delay in its receipt or any virus contained therein.  No representation, warranty or undertaking (express or implied) is given and no responsibility or liability is accepted by SpaceDev, Inc., as to the accuracy or the information contained herein or for any loss or damage (be it direct, indirect, special or other consequential) arising from reliance on it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
