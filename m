Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B6E0F6B0032
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 22:22:48 -0400 (EDT)
Received: by pdbqd1 with SMTP id qd1so14507971pdb.2
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 19:22:48 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id vk3si18379424pbc.139.2015.04.13.19.22.46
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 19:22:47 -0700 (PDT)
Date: Tue, 14 Apr 2015 11:17:06 +0900
From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH 4/9] perf kmem: Implement stat --page --caller
Message-ID: <20150414021706.GI23913@sejong>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
 <1428298576-9785-5-git-send-email-namhyung@kernel.org>
 <20150413134024.GD3200@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150413134024.GD3200@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Hi Arnaldo,

On Mon, Apr 13, 2015 at 10:40:24AM -0300, Arnaldo Carvalho de Melo wrote:
> Em Mon, Apr 06, 2015 at 02:36:11PM +0900, Namhyung Kim escreveu:
> > +static int build_alloc_func_list(void)
> > +{
> > +	int ret;
> > +	struct map *kernel_map;
> > +	struct symbol *sym;
> > +	struct rb_node *node;
> > +	struct alloc_func *func;
> > +	struct machine *machine = &kmem_session->machines.host;
> > +
> 
> Why having a blank like here?

Will remove.

> 
> > +	regex_t alloc_func_regex;
> > +	const char pattern[] = "^_?_?(alloc|get_free|get_zeroed)_pages?";
> > +
> > +	ret = regcomp(&alloc_func_regex, pattern, REG_EXTENDED);
> > +	if (ret) {
> > +		char err[BUFSIZ];
> > +
> > +		regerror(ret, &alloc_func_regex, err, sizeof(err));
> > +		pr_err("Invalid regex: %s\n%s", pattern, err);
> > +		return -EINVAL;
> > +	}
> > +
> > +	kernel_map = machine->vmlinux_maps[MAP__FUNCTION];
> > +	map__load(kernel_map, NULL);
> 
> What if the map can't be loaded?

Hmm.. yes, I need to check the return code.


> 
> > +
> > +	map__for_each_symbol(kernel_map, sym, node) {
> > +		if (regexec(&alloc_func_regex, sym->name, 0, NULL, 0))
> > +			continue;
> > +
> > +		func = realloc(alloc_func_list,
> > +			       (nr_alloc_funcs + 1) * sizeof(*func));
> > +		if (func == NULL)
> > +			return -ENOMEM;
> > +
> > +		pr_debug("alloc func: %s\n", sym->name);
> > +		func[nr_alloc_funcs].start = sym->start;
> > +		func[nr_alloc_funcs].end   = sym->end;
> > +		func[nr_alloc_funcs].name  = sym->name;
> > +
> > +		alloc_func_list = func;
> > +		nr_alloc_funcs++;
> > +	}
> > +
> > +	qsort(alloc_func_list, nr_alloc_funcs, sizeof(*func), funcmp);
> > +
> > +	regfree(&alloc_func_regex);
> > +	return 0;
> > +}
> > +
> > +/*
> > + * Find first non-memory allocation function from callchain.
> > + * The allocation functions are in the 'alloc_func_list'.
> > + */
> > +static u64 find_callsite(struct perf_evsel *evsel, struct perf_sample *sample)
> > +{
> > +	struct addr_location al;
> > +	struct machine *machine = &kmem_session->machines.host;
> > +	struct callchain_cursor_node *node;
> > +
> > +	if (alloc_func_list == NULL)
> > +		build_alloc_func_list();

And here too..


> > +
> > +	al.thread = machine__findnew_thread(machine, sample->pid, sample->tid);
> > +	sample__resolve_callchain(sample, NULL, evsel, &al, 16);
> > +
> > +	callchain_cursor_commit(&callchain_cursor);
> > +	while (true) {
> > +		struct alloc_func key, *caller;
> > +		u64 addr;
> > +
> > +		node = callchain_cursor_current(&callchain_cursor);
> > +		if (node == NULL)
> > +			break;
> > +
> > +		key.start = key.end = node->ip;
> > +		caller = bsearch(&key, alloc_func_list, nr_alloc_funcs,
> > +				 sizeof(key), callcmp);
> > +		if (!caller) {
> > +			/* found */
> > +			if (node->map)
> > +				addr = map__unmap_ip(node->map, node->ip);
> > +			else
> > +				addr = node->ip;
> > +
> > +			return addr;
> > +		} else
> > +			pr_debug3("skipping alloc function: %s\n", caller->name);
> > +
> > +		callchain_cursor_advance(&callchain_cursor);
> > +	}
> > +
> > +	pr_debug2("unknown callsite: %"PRIx64 "\n", sample->ip);
> > +	return sample->ip;
> > +}
> > +
> > +static struct page_stat *search_page(u64 page, bool create)
> >  {
> >  	struct rb_node **node = &page_tree.rb_node;
> >  	struct rb_node *parent = NULL;
> > @@ -357,6 +491,41 @@ static struct page_stat *search_page_alloc_stat(struct page_stat *stat, bool cre
> >  	return data;
> >  }
> >  
> > +static struct page_stat *search_page_caller_stat(u64 callsite, bool create)
> > +{
> > +	struct rb_node **node = &page_caller_tree.rb_node;
> > +	struct rb_node *parent = NULL;
> > +	struct page_stat *data;
> 
> Please use the "findnew" idiom to name this function, looking at only
> its name one things it searches a tree, a read only operation, but it
> may insert elements too, a modify operation.
> 
> Since we use the findnew idiom elsewhere for operations that do that,
> i.e. optimize the "new" part of "findnew" by using the "find" part,
> please use it here as well.

OK.  Will change and resend v7 soon.

Thanks for your review!
Namhyung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
