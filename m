Received: from kubu (unknown [213.80.72.14])
	by kubrik.opensource.se (Postfix) with ESMTP id 19A2F3752C
	for <linux-mm@kvack.org>; Mon, 25 Oct 2004 12:51:57 +0200 (CEST)
Subject: objrmap and nonlinear vma:s
From: Magnus Damm <damm@opensource.se>
Content-Type: text/plain
Message-Id: <1098702692.23463.123.camel@kubu.opensource.se>
Mime-Version: 1.0
Date: Mon, 25 Oct 2004 13:11:33 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello all,

I am currently investigating how to unmap a physical page belonging to a
nonlinear file backed vma. 

By studying the 2.6.9 source code and by reading the excellent VMM book
by Mel Gorman I believe that:

- physical pages belonging to linear file backed vma:s are currently
reverse mapped using the prio_tree i_mmap.

- physical pages belonging to nonlinear file backed vma:s are currently
reverse mapped using the linked list i_mmap_nonlinear.

Please let me know if something above is incorrect.

The reverse mapping code for nonlinear vma:s does not seem to scale very
well today with the linked list implementation. It seems to me that the
assumption is made that the number of users of nonlinear vma:s are few
and that they probably not very often want do anything resulting in a
reverse mapping operation.

Some questions:

1) Is everyone happy with the solution today? Is the linked list
implementation fast enough? It seems to me that the nonlinear code in
try_to_unmap_file() is good enough for swap but does not always unmap
the requested page. This behavior is not very suitable for memory
hotswap. And a linear scan of all page tables is not very suitable for
swap.

2) Any particular reason why the prio_tree is avoided for nonlinear
vma:s? We could modify the code to use one "union shared" together with
one vm_pgoff per page in struct vm_area_struct for nonlinear vma:s. That
way it would be possible to rmap nonlinear vma:s with the prio_tree. But
maybe that is unholy misuse of the prio_tree data structure, who knows.

3) Using prio_tree to rmap nonlinear vma:s like above would of course
lead to a higher memory use per page belonging to a nonlinear vma. That
raises the question why nonlinear vma:s aren't implemented as several
vma:s - one vma per page? I mean, if remap_file_pages() should be able
to change protection per page in the future - exactly what do we have
then? Several vma:s?

Thanks!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
